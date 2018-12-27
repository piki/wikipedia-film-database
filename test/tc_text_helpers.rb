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

	def text_extract_matched_braces
		assert_equal("{{abc}}", Movie.extract_matched_braces("{{abc}}def"))
		assert_equal("{{abc{{def\n}}\nghi}}", Movie.extract_matched_braces("{{abc{{def\n}}\nghi}}jkl"))
		assert_equal("{{abc{{def}}}}", Movie.extract_matched_braces("{{abc{{def}}}}jkl"))
	end

	def test_find_end_braces
		assert_equal(10, Movie.find_end_braces("abc{{def}}ghi", 3))
		assert_equal(nil, Movie.find_end_braces("abc{{defghi", 3))
		assert_equal(10, Movie.find_end_braces("abc{{def}}ghi}}", 3))
		assert_equal(17, Movie.find_end_braces("abc{{de{{f}}ghi}}", 3))
		assert_equal(9, Movie.find_end_braces("abc{{de}}f{{ghi}}", 3))
		assert_equal(17, Movie.find_end_braces("abc{{de}}f{{ghi}}", 10))
	end

	def test_de_tagify
		assert_equal("abc", Movie.de_tagify("abc"))
		assert_equal("abcdef", Movie.de_tagify("abc<ref blah blah>def</ref>"))
		assert_equal("abcdef", Movie.de_tagify("abc<ref blah blah />def"))
		assert_equal("abcdef", Movie.de_tagify("abc<!-- comment -->def"))
	end
end
