require 'ox'

class Parser < ::Ox::Sax
	def self.debug
		@@debug ||= false
	end
	def self.debug=(val)
		@@debug = val
	end

	def initialize(&block)
		@depth = 0
		@block = block
		reset
	end

	def start_element(name)
		@depth += 1
		#puts (" " * (@depth*2)) + name.to_s

		case name
			when :text
				@in_text_tag = true
			when :title
				@in_title_tag = true
			when :redirect
				@in_redirect_tag = true
		end
	end

	def attr(name, str)
		return unless @in_redirect_tag && name == :title
		@redirect = str
	end

	def end_element(name)
		@depth -= 1

		case name
			when :text
				@in_text_tag = false
			when :title
				@in_title_tag = false
			when :redirect
				@in_redirect_tag = false
			when :page
				end_page
		end
	end

	def text(value)
		if @in_text_tag
			@text << value
		elsif @in_title_tag
			@title << value
		end
	end

private
	def end_page
		if @title =~ /^(rough \s+)? draft:/xi
			puts "SKIP: #{@title}" if Parser.debug
			reset
			return
		end
		if !@redirect.empty?
			puts "REDIRECT: #{@title} -> #{@redirect}" if Parser.debug
			reset
			return
		end
		begin
			m = Movie.parse(@title, @text)
		rescue => e
			puts "EXCEPTION parsing #{@title.inspect}:"
			puts e
			puts e.backtrace
			raise unless Parser.debug
		end
		@block.call(m) if m
		reset
	end

	def reset
		@in_text_tag = @in_title_tag = @in_redirect_tag = false
		@text = ""
		@title = ""
		@redirect = ""
	end
end
