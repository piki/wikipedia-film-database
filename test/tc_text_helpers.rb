#!/usr/bin/ruby

require 'test/unit'
require '../lib/movie'
require '../lib/parser'

class TestTextHelpers < Test::Unit::TestCase
	def test_get_cast
		assert_equal([], Movie.get_cast("==Cast==\nfoo"))
		assert_equal([], Movie.get_cast("abcd\n==Cast==\nfoo"))
		assert_equal([], Movie.get_cast("abcd\n== Cast ==\nfoo"))
		assert_equal([], Movie.get_cast("abcd\n=== Cast ===\nfoo"))
		assert_equal([], Movie.get_cast("abcd\n=== Cast {{junk}} ===\nfoo"))
		assert_equal([], Movie.get_cast("abcd\n==Main cast==\nfoo"))
		assert_equal(nil, Movie.get_cast("abcd\n==Cat==\nfoo"))
	end

	def test_plain_textify
		assert_equal("AfooB", Movie.plain_textify("A{{ill|foo|bar}}B"))
		assert_equal("AtextB", Movie.plain_textify("A[[target|text]]B"))
		assert_equal("AfooB CtextD", Movie.plain_textify("A{{ill|foo|bar}}B C[[target|text]]D"))
	end

	def test_plainlist
		assert_equal("", Movie.convert_plainlists(""))
		assert_equal("abc", Movie.convert_plainlists("abc"))
		assert_equal("XX{{ubl|A|B}}YY", Movie.convert_plainlists("XX{{Plainlist|\n* A\n* B\n}}YY"))
	end
end
