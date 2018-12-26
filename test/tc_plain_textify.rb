#!/usr/bin/ruby

require 'test/unit'
require '../lib/movie'
require '../lib/parser'

class TestPlainTextify < Test::Unit::TestCase
	def test_plain_textify
		assert_equal("AfooB", Movie.plain_textify("A{{ill|foo|bar}}B"))
		assert_equal("AtextB", Movie.plain_textify("A[[target|text]]B"))
		assert_equal("AfooB CtextD", Movie.plain_textify("A{{ill|foo|bar}}B C[[target|text]]D"))
	end
end
