# https://simple.wikipedia.org/wiki/Wikipedia:Wikitable
class WikiTable
	attr_reader :data
	def initialize
		@row = 0
		@col = nil
		@data = []
	end

	def line(line)
		raise "table is frozen: #{line}" if @frozen
		return if @data.empty? && line =~ /^{\|/  # ignore first line
		return if line =~ /^\|\+/  # ignore table caption

		if line =~ /^\|-/
			return if @data.empty?   # optional |- before the first row data
			@row += 1
			@col = nil
			@open_cell = false
			return
		end

		if line =~ /^\|}/
			@frozen = true
			return
		end

		if line =~ /^(?:! | \|) \s* (.*)/x
			next_cell
			line = $1
		end

		# split at || or !!
		line.split(/\s* (?: \|\| | !!) \s*/x).each_with_index do |tok, idx|
			next_cell unless idx == 0
			unless @col
				puts "ERROR: text #{tok.inspect} outside any cell" if Parser.debug
				next
			end
			# If there's any format specifier, discard up to the first '|'.
			# But disallow [ and { before the | as a hacky way of avoiding
			# getting fooled by [links] and {{commands}}.
			if tok =~ /^\s* (?: [^\[{]+?) \| \s* (.*)/x
				tok = $1
			end
			@data[@row] ||= []
			if @data[@row][@col]
				@data[@row][@col] << "\n"
				@data[@row][@col] << tok
			else
				@data[@row][@col] ||= tok
			end
		end
		@open_cell = true
	end

private
	def next_cell
		if !@col
			@col = 0
		else
			@col += 1
		end
	end
end
