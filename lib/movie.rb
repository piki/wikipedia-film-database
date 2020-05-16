# This file is where the bulk of the work happens.  The `Movie` is a
# simple structure, and `Movie.parse` is a factory that converts Wikipedia
# articles to Movie objects.
#
# The two most important functions are `Movie.get_infobox` and
# `Movie.get_cast`, which extract structured data from each article's the
# infobox (right sidebar) and Cast section, respectively.
require 'yajl'
$:.unshift File.expand_path "../../lib", __FILE__
require 'wikitable'
require 'unicode'

class Movie
	attr_accessor :title, :cast, :directors, :producers, :companies, :year

	def initialize(title, year)
		@title = title
		@year = year
	end

	# Convert all plaintext names into links if they appear as links
	# anywhere else in the same movie.  For example, if Steven Spielberg
	# appears as both "director=[[Steven Spielberg]]" and "producer=Steven
	# Spielberg", this function will make both appear as links.  This is
	# fairly common on Wikipedia: only the first occurrence of a name will
	# be a link.  Without this function, "[[name]]" and "name" would appear
	# to be two different people.
	def linkify
		linkmap = {}
		[ @cast, @directors, @producers, @companies ].compact.each do |arr|
			arr.each do |name|
				plain = Movie.delinkify(name)
				linkmap[plain] = name unless plain == name
			end
		end

		[ @cast, @directors, @producers, @companies ].compact.each do |arr|
			arr.each_with_index do |name, idx|
				if linkmap[name]
					arr[idx] = linkmap[name]
				end
			end
			arr.uniq!
		end
	end

	# Parse an article and return a Movie object.
	#  - title: the title of the article, from <title>...</title>
	#  - text: the full text of the article
	# Returns a Movie object, or nil.
	def self.parse(title, text)
		infobox = get_infobox(text)
		puts "INFOBOX: #{infobox.inspect}" if infobox && Parser.debug

		# not a film, even if it has a cast
		return if !infobox && title !~ /film\)$/

		# page for deletion
		return if title =~ /Wikipedia:Articles for deletion/

		cast = get_cast(text)
		if !cast
			puts "ERROR: \"#{title}\" is a film with no cast" if Parser.debug
			cast = []
		end

		m = Movie.new(title, nil)

		if infobox
			cast = (infobox["stars"] + cast).uniq if infobox["stars"]
			m.year      = infobox["year"]      if infobox["year"]
			m.directors = infobox["directors"] if infobox["directors"]
			m.producers = infobox["producers"] if infobox["producers"]
			m.companies = infobox["companies"] if infobox["companies"]
		end

		if cast.empty?
			puts "ERROR: \"#{title}\" is a film with empty cast" if Parser.debug
		end
		m.cast = cast
		m.linkify
		m
	end

	def to_json
		h = {
			"title" => @title
		}
		h["cast"] = @cast if @cast
		h["directors"] = @directors if @directors
		h["producers"] = @producers if @producers
		h["companies"] = @companies if @companies
		h["year"] = @year if @year

		@@encoder ||= Yajl::Encoder.new
		@@encoder.encode(h)
	end

private
	# Find an "{{Infobox film ...}}" block and convert it to a hash with the
	# release year and lists of actors, director(s), producer(s), companies.
	# Keys in the infobox are standardized, but values are prose in various
	# forms:
	#  - scalar, like "director = Tim Burton"
	#  - structured lists, like "starring = {{ubl|...}" or
	#    "starring = {{plainlist|\n...}}
	#  - unstructured lists like "distributor = Warner<br />Paramount"
	# Parameters:
	#  - `text` is a string containing the whole infobox, generally the
	#    whole article
	# Returns a hash with zero or more of the following keys: directors,
	# producers, stars, companies, and year.  Year is an integer, and all
	# others are arrays of strings.
	def self.get_infobox(text)
		m = /{{Infobox \s+ film \s* (\| | $)/xi.match(text)
		return nil unless m
		ofs = m.begin(0)

		ret = {}
		convert_plainlists(extract_matched_block(text[ofs..-1], "{{", "}}")).lines[1..-1].each do |line|
			next unless line =~ /^\s* \| \s* ([^=]+?) \s* = \s* (.*)/x
			key, value = $1, $2.strip
			next if value.empty?
			case key
				when "director", "directors"
					if val = parse_infobox_list(value)
						ret["directors"] = val
					end
				when "producer", "producers"
					if val = parse_infobox_list(value)
						ret["producers"] = val
					end
				when "starring"
					if val = parse_infobox_list(value)
						ret["stars"] = val
					end
				when "studio", "distributor", "production companies"
					if val = parse_infobox_list(value)
						ret["companies"] ||= []
						ret["companies"] += val
					end
				when "released"
					if value =~ /\b ((?: 18 | 19 | 20) \d \d) \b/x
						ret["year"] = $1.to_i
					end
				when "runtime"
					raise MovieSeriesException.new if value =~ /\bTotal\b/
			end
		end
		ret["companies"].uniq! if ret["companies"]
		ret
	end

	# Convert {{Plainlist|...}} commands to {{ubl|...} commands, which are
	# easier for the rest of get_infobox to handle, because they fit on a
	# single line.
	# The `str` parameter should be the entire infobox, not just the line
	# the plainlist begins on, because plainlists can span several lines.
	def self.convert_plainlists(str)
		while m = /{{Plain \s* list \s* \|(.*?)/xim.match(str)
			ofs = m.begin(0)
			eofs = find_end_braces(str, ofs)
			break unless eofs

			body = str[ofs+2 ... eofs-2]  # omit {{ and }}
			entries = body.lines[1..-1].map { |x| x.gsub(/^\s* \* \s* /x, '').chomp }
			
			replacement = "{{ubl|#{entries.join('|')}}}"
			str = str[0...ofs] + replacement + str[eofs..-1]
		end
		str
	end

	# Parse a single line from an infobox.  In most cases, the value is a
	# scalar, but in some, it's a {{ubl|...}} command or an "A<br />B<br />C"
	# sequence that needs to be parsed out into an array.
	#   - `line` is a single line from an infobox
	# The return value is always an array, possibly containing just one
	# element, of all the values found on the infobox line.
	def self.parse_infobox_list(line)
		if (m = /{{(?: ubl | unbulleted \s+ list) \| (.*)/ix.match(line)) && (eofs = find_end_braces(line, m.begin(0)))
			body = line[m.begin(1)...eofs-2]
			body = expand_brace_commands(body)
			body = remove_comments(body)
			arr = split_around_markup(body, "|")
		else
			arr = line.split(/,\s+/)
			if arr.size >= 3
				arr.last.sub!(/and\s+/, '')
			else
				arr = line.split(/\s* <br \s* \/? > \s*/xi)  # <br/> or <br>
			end
		end
		arr = arr.map { |tok| strip_parenthetical(plain_textify(tok)).strip }
		arr.select! { |x| is_legal_actor?(x) }
		arr
	end

	def self.remove_comments(str)
		str.gsub(/<!-- .*? -->/x, "")
	end
	
	# Split the string `str` into an array, using `sep` as the field
	# separator.  This is like `str.split(sep)`, except that it ignores
	# instances of `sep` that appear in `[[...]]` and `{{...}}` markup
	# sequences.
	#  e.g.,
	#    split_around_markup("a|b|c", "|") -> ["a", "b", "c"]
	#    split_around_markup("a|[b|B]|c", "|") -> ["a", "[b|B]", "c"]
	def self.split_around_markup(str, sep)
		ret = []
		ofs = 0
		while !str.empty?
			sep_ofs = str.index(sep, ofs)
			brace_ofs = str.index("{{", ofs)
			bracket_ofs = str.index("[[", ofs)
			next_ofs = [ sep_ofs, brace_ofs, bracket_ofs ].compact.min
			case next_ofs
				when nil
					ret << str
					str = ""
				when sep_ofs
					ret << str[0...sep_ofs]
					str = str[sep_ofs+1..-1]
					ofs = 0
				when brace_ofs
					ofs = find_block_end(str, brace_ofs, "{{", "}}") || str.size
				when bracket_ofs
					ofs = find_block_end(str, bracket_ofs, "[[", "]]") || str.size
				else
					fail
			end
		end
		ret
	end

	# Parse the "Cast" section out of an article, and return the cast list
	# as an array.  The Cast section can appear in several formats: bulleted
	# lists, individual lines, tables, prose, etc.  It is this function's
	# job to parse all such formats.
	# This function does not parse the "starring" list in the infobox.
	#   - `text` is the article body, or at least the Cast section
	# The return value is an array of actors' names.
	def self.get_cast(text)
		# Allow several different formats for the Cast section heading:
		#   Main cast, Cast, Casting
		m = /^ =+ \s* (?:Main \s+ cast|Cast|Casting) \b (.*)/xmi.match(text)
		return nil unless m

		ofs = m.begin(0)
		fail unless text[ofs] == '='
		fail unless ofs == 0 || text[ofs-1] != '='

		# Figure out what header depth (e.g., "== Cast ==" is 2) the Cast
		# section is.
		section_depth = 0
		while text[ofs+section_depth] == '='
			section_depth += 1
		end

		# Parse from the beginning of the Cast section, to either the end of
		# the section or the end of the article, looking for lines that
		# identify an actor.
		ret = []
		table = nil
		text[ofs..-1].lines[1..-1].each do |line|
			# Stop when we reach the beginning of another (equal or higher) section
			break if is_section_start(line, section_depth)

			if !table && line =~ /^{\|/
				table = WikiTable.new
				next
			end
			if table
				table.line(line)
				if line =~ /^\|}/
					# end of table
					actors = get_actors_from_table(table.data)
					actors.each do |actor|
						ret << actor if is_legal_actor?(actor)
					end
					table = nil
				end
				next
			end

			line.gsub!(/{{Cast listing\|/i, '')
			line = plain_textify(line)
			break if /^ [=']+ \s* cast \s+ notes \b/ix.match(line)

			# Look for bulleted-list lines, like "* Actor Name as Character Name"
			# Also include indented lines like "** Actor Name as young Character Name"
			if line =~ /^:? \s* \*+ \s* (.*)/x
				line = $1
			else
				next
			end

			actor = get_actor_from_line(line)
			ret << actor if is_legal_actor?(actor)
		end

		ret
	end

	def self.get_actors_from_table(data)
		top_row = data.first
		return [] unless top_row
		actor_columns = (0...top_row.size).select { |idx| top_row[idx] =~ /\b (actor|actress) \b/ix || top_row[idx] =~ /^ \s* cast \b/ix }
		if actor_columns.empty?
			actor_columns = (0...top_row.size).select { |idx| top_row[idx] =~ /^name$/i }
		end
		puts "Cast table: #{top_row.inspect} => #{actor_columns.inspect}" if Parser.debug

		# If there are no headers with the word "actor", it's a free-form
		# table.  Look for cells with /^as Character Name/ or
		# /Actor Name as Character Name/.
		if actor_columns.empty?
			ret = []
			data.each do |row|
				next unless row
				row.each_with_index do |cell, idx|
					if cell =~ /\S \s+ as \s+ \S/x
						cell = plain_textify(cell)
						actor = get_actor_from_line(cell)
					elsif idx > 0 && cell =~ /^ \s* (?: as | '''......''' ) \s+ \S/x
						actor = get_actor_from_line(plain_textify(row[idx-1]))
					end
					if is_legal_actor?(actor)
						puts "actor from table cell #{cell.inspect}: #{actor.inspect}" if Parser.debug
						ret << actor
					end
				end
			end
			return ret
		end

		# This is a well formed table with one or more "actor" headers, so
		# just pick out cells from every "actor" column.
		ret = []
		data[1..-1].each do |row|
			next unless row
			actor_columns.each do |col|
				next unless row[col]
				actor = get_actor_from_line(plain_textify(row[col]))
				if is_legal_actor?(actor)
					puts "actor from table col #{col}: #{actor.inspect}" if Parser.debug
					ret << actor
				end
			end
		end
		ret
	end

	EPITHETS = [ /^Director\s+/, /^Veteran.*(?=\[\[)/ ]
	def self.get_actor_from_line(line)
		was = line.dup
		# Strip leading epithets
		EPITHETS.each do |pattern|
			line.gsub!(pattern, '')
		end

		# If the line begins with a link, and the text of that link is an
		# actor's name, then return the whole link.
		if line[0..1] == "[["
			block = extract_matched_block(line, "[[", "]]")
			bare = delinkify(block)
			return block if get_bare_actor_from_line(bare) == bare
		end

		# Otherwise, try to parse it as plain text.
		get_bare_actor_from_line(line)
	end

	def self.get_bare_actor_from_line(line)
		# The actor name is the concatenation of all capitalized tokens at
		# the beginning of the line, with special consideration for quoted
		# nicknames and lowercase name-joining words like "de la".
		actor = ""
		line.split(/(?: [ :] | &nbsp;)+/x).each do |word|
			word.gsub!(/[-*]$/, '')
			if word =~ /^["']/ || (word[0] && Unicode.downcase(word[0]) != word[0]) || is_name_connector(word)
				actor << " " unless actor.empty?
				actor << word
			else
				break
			end
		end
		actor
	end

	# Chop trailing parenthetical, like "Kevin Bacon (uncredited)"
	# Also chop trailing slash-alternate, like "Kevin Bacon / some detail"
	# Also chop trailing dash, comma, and asterisk
	def self.strip_parenthetical(str)
		str.
			gsub(/\s+ \( [^)]+ \) \s* $/x, '').
			gsub(/\s+ \/ .* $/x, '').
			gsub(/[-,*]$/, '')
	end

	def self.plain_textify(str)
		expand_brace_commands(de_tagify(str))
	end

	def self.de_tagify(str)
		str.
			gsub(/<ref [^>]*?>.*?<\/ref>/x, '').  # remove <ref>...</ref> spans
			gsub(/<\/? \s* ref .*?>/x, '').       # remove residual <ref> tags
			gsub(/<!-- .*? -->/x, '')             # remove <!-- --> comments
	end

	def self.delinkify(str)
		str.gsub(/\[\[ (.*?) \]\]/x) do |sub|
			tok = $1.split('|', 2)
			# tok.first is the title of the target page
			# tok.last is the link text
			# We use the link text (tok.last) here, though an argument could be
			# made for either choice.  In favor of using link text:
			#  - Generally matches non-link usage elsewhere in the page.  A name
			#    might be listed with a link in the cast and without a link in
			#    the infobox.  The presented text for those names generally
			#    matches.
			#  - Sometimes individual actors don't have pages, but page authors
			#    have added links for those actors to some more general page.
			#    For example, in "Four Daughters," both Rosemary Lane and Lola
			#    Lane link to the page called "Lane Sisters."  Needless to say,
			#    Lane Sisters is not the name of an actress.
			#    - This is the main reason.
			# But, here are the arguments in favor of using the title of the
			# target page:
			#  - It fixes aliasing.  Sometimes an actor will have several names
			#    (e.g., with/without a middle initial, with/without Jr.,
			#    with/without a pseudonym, before/after a name change).
			#    Wikipedia editors tend to clean up duplicate pages on the same
			#    subject, but they're much less likely to clean up article text
			#    that mentions the same person by two different names.  In fact,
			#    that may even be desirable: crediting a person exactly as
			#    they're listed in the cast, for example, by the name they had
			#    at the time the film was made.
			#    - But: it's still possible for two mentions to have different
			#      link text for the same person, using redirect articles.  So
			#      to fully realize the benefits of a switch to using tok.first,
			#      we'd also have to build a map of all redirect pages.
			#  - It fixes name collisions.  Two people may have the same
			#    presented name, but if they're really two different people,
			#    they should have two different Wikipedia pages.  SAG rules help
			#    a little here (names have to be unique in cast lists of major
			#    motion pictures, IIUC), but it's unlikely that Wikipedia always
			#    follows SAG rules.  So using tok.last might end up treating
			#    Someone and Someone Jr. as the same person, if Someone Jr. is
			#    sometimes mentioned as just "Someone."
			#  - It makes links on oracleofbacon.org work better, because they
			#    always go to the right page, instead of to a fuzzy match.
			#    There's a simpler way to realize that benefit, though, which is
			#    to make each actor (and film's) page title a piece of metadata,
			#    rather than making it the primary ID.
			tok.last
		end
	end

	def self.extract_matched_block(str, ldelim, rdelim)
		eofs = find_block_end(str, 0, ldelim, rdelim)
		eofs ? str[0...eofs] : str
	end

	def self.find_end_braces(str, ofs)
		find_block_end(str, ofs, "{{", "}}")
	end

	def self.find_block_end(str, ofs, ldelim, rdelim)
		fail "expected #{ldelim.inspect} but got #{str.inspect}" unless str[ofs..ofs+1] == ldelim
		ofs += 2
		depth = 1
		while depth > 0
			rofs = str.index(rdelim, ofs)
			return unless rofs
			lofs = str.index(ldelim, ofs)
			if lofs && lofs < rofs
				ofs = lofs + 2
				depth += 1
			else
				ofs = rofs + 2
				depth -= 1
			end
		end
		ofs
	end

	def self.expand_brace_commands(str)
		while left = str.index("{{") do
			right = find_end_braces(str, left) || str.size
			inner = str[(left+2)...(right-2)]
			tok = split_around_markup(inner, "|")
			return str if tok.nil? || tok.empty?
			str[left...right] = x = case tok.first.downcase
				# https://en.wikipedia.org/wiki/Template:Anchor
				when "anchor"
					""

				# https://en.wikipedia.org/wiki/Template:Interlanguage_link
				when "ill", "interlanguage link multi"
					lt = tok.grep(/^lt \s* =/ix)
					if lt.any?
						lt = lt.first.split(/\s* = \s*/x, 2)[1]
						"[[#{tok[1]}|#{lt}]]"
					else
						"[[#{tok[1]}]]"
					end

				# https://en.wikipedia.org/wiki/Template:Sortname
				when "sortname"
					name = tok[1..2].join(' ')
					case tok[3]
						when /dab=(.*)/
							"[[#{name} (#{$1})|#{name}]]"
						when /nolink=y/
							name
						else
							"[[#{name}]]"
					end

				# https://en.wikipedia.org/wiki/Template:Sort
				when "sort"
					tok[2]

				else
					puts "BRACE COMMAND: \"#{inner}\"" if Parser.debug
					""
			end
		end
		str
	end

	# Is the string the beginning of a new section with at most `max_prefix` '=' characters?
	# Returns true if the string begins with [1,max_prefix] '=' characters.
	def self.is_section_start(line, max_prefix)
		return false unless line =~ /^(=+)/
		return $1.size >= 1 && $1.size <= max_prefix
	end

	WORD_CONNECTORS = [ "von", "van", "de", "la", "du", "del", "the", "ter", "der" ].to_set.freeze
	def self.is_name_connector(word)
		WORD_CONNECTORS.include?(word) || /^(?: d' | o' | de[A-Z])/x.match(word)
	end

	ACTOR_NAME_BLOCKLIST = [ "The", "In", "Director", /\b see \s+ below \b/xi, /^(and\s+)? other/xi, "''", "[[", "]]", "A", "An" ]
	MIN_NAME_LENGTH = 2
	def self.is_legal_actor?(str)
		str && str.size >= MIN_NAME_LENGTH && !ACTOR_NAME_BLOCKLIST.any? {|pattern| pattern === str }
	end
end

class MovieSeriesException < Exception; end
