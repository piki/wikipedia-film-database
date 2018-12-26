require 'yajl'

class Movie
	attr_accessor :title, :cast, :directors, :producers, :companies, :year

	def initialize(title, year)
		@title = title
		@year = year
	end

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
			return
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
	def self.get_infobox(text)
		ofs = text.index("{{Infobox film")
		return nil unless ofs

		ret = {}
		text[ofs..-1].lines[1..-1].each do |line|
			break if line == "}}"
			p line if Parser.debug
			next unless line =~ /^\s* \| \s* ([^=]+?) \s* = \s* (.*)/x
			key, value = $1, $2
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

	def self.parse_infobox_list(str)
		if str =~ /{{ubl\|(.*?)}}/
			delinkify($1).split('|').map{|s| plain_textify(s)}
		else
			[ plain_textify(str) ]
		end
	end

	def self.get_cast(text)
		m = /^ =+ \s* (?:Main \s+ cast|Cast|Casting) \b (.*)/xmi.match(text)
		return nil unless m
		
		ofs = m.begin(0)
		fail unless text[ofs] == '='
		fail unless ofs == 0 || text[ofs-1] != '='

		section_depth = 0
		while text[ofs+section_depth] == '='
			section_depth += 1
		end

		ret = []
		text[ofs..-1].lines[1..-1].each do |line|
			break if is_section_start(line, section_depth)
			line = plain_textify(line)
			break if /^ [=']+ \s* cast \s+ notes \b/ix.match(line)

			# Try to extract an actor name from that line.  Sample patterns include:
			# * [[Cleavon Little]] as Sheriff Bart
			# * Richard Collier plays Dr. Samuel Johnson
			# *[[Rob Cowan (actor)|Rob Cowan]] - Skip
			# ** [[Dominic Savage]] voices young Bullingdon
			# * [[Philip Stone]]  as Graham
			# * [[Ben Affleck]] (''uncredited'') as Basketball Player #10
			# *George Roth as Eddie
			# * [[Van Williams]] (''uncredited voice'') as President [[ ...
			# There can be {{}} control blocks, [[]] image files, or just plain text above the actual cast list.
			# There can be arbitrarily long character descriptions after the "as character-name."


			if line =~ /^\s* \* \s* (.*)/x
				line = $1
			else
				next
			end

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

			# FIXME:
			#   cast in tables: emile-zola, holy-grail, original-sin, totoro, good-earth, four-daughters, air-command, spirited, random-harvest
			#   lead actors only listed in prose: roman-holiday
			#
			# FIXME:
			#    bad actors:
			#      single-word names: Mars, Rufus, Armelle, Otto, Sabu, Skippy, Margo, Sapic, Trigger, Ta-Tanisha
			#      :fr: Claudio Todeschini
			#      Christopher Walken/Ray Park
			#      Pat O'Malley''
			#      Michael Visocoff, S.T.  (?)
			#      Ferdinand Gottschalk and Jane Kerr
			#      70px Jean Harlow  (and others)
			#      Baby Jane Holzer<ref name=Berkeley />
			#      Hanks' son, Colin, appears
			#
			#   "A, Jr." is a name, but "A, B, and C" is three.

		end

		ret
	end

	# Chop trailing parenthetical, like "Kevin Bacon (uncredited)"
	def self.strip_parenthetical(str)
		str.gsub(/ \(.*/, '')
	end

	def self.plain_textify(str)
		expand_brace_commands(delinkify(str))
	end

	def self.delinkify(str)
		str.gsub(/\[\[(.*?)\]\]/) do |sub|
			tok = $1.split('|', 2)
			# tok.first is the title of the target page
			# tok.last is the anchor text
			tok.last
		end
	end

	def self.extract_matched_braces(str)
		fail unless str[0..1] == "{{"
		ofs = 2
		depth = 1
		while depth > 0
			lofs = str.index("{{", ofs)
			rofs = str.index("}}", ofs)
			if lofs < rofs
				ofs = lofs + 2
				depth += 1
			else
				ofs = rofs + 2
				depth -= 1
			end
		end
		str[0...ofs]
	end

	def self.expand_brace_commands(str)
		str.gsub(/{{(.*?)}}/) do |sub|
			tok = $1.split('|', 3)
			case tok.first
				when "anchor"
					""
				when "ill", "Interlanguage link multi"
					tok[1]
				else
					puts "BRACE COMMAND: \"#{$1}\"" if Parser.debug
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
