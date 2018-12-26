#!/usr/bin/ruby

require 'test/unit'
require '../lib/movie'
require '../lib/parser'

class TestGetCast < Test::Unit::TestCase
	def test_get_cast
		assert_equal([], Movie.get_cast("==Cast==\nfoo"))
		assert_equal([], Movie.get_cast("abcd\n==Cast==\nfoo"))
		assert_equal([], Movie.get_cast("abcd\n== Cast ==\nfoo"))
		assert_equal([], Movie.get_cast("abcd\n=== Cast ===\nfoo"))
		assert_equal([], Movie.get_cast("abcd\n=== Cast {{junk}} ===\nfoo"))
		assert_equal([], Movie.get_cast("abcd\n==Main cast==\nfoo"))
		assert_equal(nil, Movie.get_cast("abcd\n==Cat==\nfoo"))
	end
end
