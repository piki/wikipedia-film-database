# This file is where the bulk of the work happens.  The `Movie` is a
# simple structure, and `Movie.parse` is a factory that converts Wikipedia
# articles to Movie objects.
#
# The two most important functions are `Movie.get_infobox` and
# `Movie.get_cast`, which extract structured data from each article's the
# infobox (right sidebar) and Cast section, respectively.
require 'yajl'

class Movie
	attr_accessor :title, :cast, :directors, :producers, :companies, :year

	def initialize(title, year)
		@title = title
		@year = year
	end

	# Parse an article and return a Movie object.
	#  - title: the title of the article, from <title>...</title>
	#  - text: the full text of the article
	# Returns a Movie object, or nil.
	def self.parse(title, text)
		infobox = get_infobox(text)
		p infobox if infobox && Parser.debug

		if !infobox && title !~ /film\)$/
			# not a film, even if it has a cast
			return
		end

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

		title = strip_parenthetical(title)
		puts "FILM ===> #{title}" if Parser.debug
		if cast.empty?
			puts "ERROR: \"#{title}\" is a film with empty cast" if Parser.debug
		end
		cast.each do |actor|
			puts "  ACTOR ===> #{actor}" if Parser.debug
		end
		m.cast = cast
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
		ofs = text.index("{{Infobox film")
		return nil unless ofs

		ret = {}
		convert_plainlists(extract_matched_braces(text[ofs..-1])).lines[1..-1].each do |line|
			next unless line =~ /^\s* \| \s* ([^=]+?) \s* = \s* (.*)/x
			key, value = $1, $2.strip
			next if value.empty?
			case key
				when "director"
					if val = parse_infobox_list(value)
						ret["directors"] = val
					end
				when "producer"
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
					if value =~ /\b ((?: 19 | 20) \d \d) \b/x
						ret["year"] = $1.to_i
					end
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
		if m = /{{ubl\|.*/.match(line)
			if eofs = find_end_braces(line, m.begin(0))
				body = line[m.begin(0)+6...eofs-2]
				return expand_brace_commands(delinkify(body)).split('|').map{|s| strip_parenthetical(plain_textify(s))}
			end
		end
		arr = line.split(/<br \s* \/? >/xi)  # <br/> or <br>
		arr.map { |tok| plain_textify(tok) }
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
		text[ofs..-1].lines[1..-1].each do |line|
			# Stop when we reach the beginning of another (equal or higher) section
			break if is_section_start(line, section_depth)
			line = plain_textify(line)
			break if /^ [=']+ \s* cast \s+ notes \b/ix.match(line)

			# Look for bulleted-list lines, like "* Actor Name as Character Name"
			if line =~ /^\s* \* \s* (.*)/x
				line = $1
			else
				next
			end

			# The actor name is the concatenation of all capitalized tokens at
			# the beginning of the line, with special consideration for quoted
			# nicknames and lowercase name-joining words like "de la".
			actor = ""
			line.split(/[ :]/).each do |word|
				word.gsub!(/-$/, '')
				if word =~ /^[A-Z"']/ || is_name_connector(word)
					actor << " " unless actor.empty?
					actor << word
				else
					break
				end
			end

			ret << actor if is_legal_actor?(actor)
		end

		ret
	end

	# Chop trailing parenthetical, like "Kevin Bacon (uncredited)"
	def self.strip_parenthetical(str)
		str.gsub(/\s+ \( [^)]+ \) \s* $/x, '')
	end

	def self.plain_textify(str)
		expand_brace_commands(de_tagify(delinkify(str)))
	end

	def self.de_tagify(str)
		str.
			gsub(/<\/? \s* ref .*?>/x, '').  # remove <ref> tags
			gsub(/<!-- .*? -->/x, '')        # remove <!-- --> comments
	end

	def self.delinkify(str)
		str.gsub(/\[\[ (.*?) \]\]/x) do |sub|
			tok = $1.split('|', 2)
			# tok.first is the title of the target page
			# tok.last is the anchor text
			tok.last
		end
	end

	def self.extract_matched_braces(str)
		eofs = find_end_braces(str, 0)
		eofs ? str[0...eofs] : str
	end

	def self.find_end_braces(str, ofs)
		find_block_end(str, ofs, "{{", "}}")
	end

	def self.find_block_end(str, ofs, ldelim, rdelim)
		fail unless str[ofs..ofs+1] == ldelim
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
		str.gsub(/{{(.*?)}}/) do |sub|
			tok = $1.split('|', 4)
			case tok.first.downcase
				# https://en.wikipedia.org/wiki/Template:Anchor
				when "anchor"
					""

				# https://en.wikipedia.org/wiki/Template:Interlanguage_link
				when "ill", "Interlanguage link multi"
					tok[1]

				# https://en.wikipedia.org/wiki/Template:Sortname
				when "sortname"
					tok[1..2].join(' ')

				# https://en.wikipedia.org/wiki/Template:Sort
				when "sort"
					tok[2]

				else
					puts "BRACE COMMAND: \"#{$1}\"" if Parser.debug
					""
			end
		end
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

	def self.is_legal_actor?(str)
		!str.empty? && str != "The" && str != "In"
	end
end
