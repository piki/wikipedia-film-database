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

	def test_get_infobox
		assert_equal(nil, Movie.get_infobox("foo bar"))
		assert_equal(nil, Movie.get_infobox("{{Infobox film awards"))
		assert_equal(nil, Movie.get_infobox("{{Infobox film series"))
		assert_equal(nil, Movie.get_infobox("{{Infobox film festival"))
		assert_equal({}, Movie.get_infobox("{{Infobox film"))
		assert_equal({}, Movie.get_infobox("{{Infobox film\n}}"))
		assert_equal({}, Movie.get_infobox("{{Infobox film |foo}}"))
		assert_equal({"directors"=>["aaa","bbb"]}, Movie.get_infobox("{{Infobox film\n| director=aaa<br>bbb\n}}"))
		assert_equal({"producers"=>["aaa"]}, Movie.get_infobox("{{Infobox film\n| producer=aaa\n}}"))
		assert_equal({"year"=>1988}, Movie.get_infobox("{{Infobox film\n| released = {{Film date|df=yes|1988|04|16}}\n}}"))
		assert_equal({"stars"=>["aaa","bbb","ccc"]}, Movie.get_infobox("{{Infobox film\n| starring={{ubl|aaa|bbb|ccc}}\n}}"))
		assert_equal({"stars"=>["aaa","bbb","ccc"]}, Movie.get_infobox("{{Infobox film\n| starring={{plainlist|\n* aaa\n* bbb\n* ccc}}\n}}"))
		assert_equal({"stars"=>[]}, Movie.get_infobox("{{Infobox film\n| starring=see below\n}}"))
		assert_equal({"stars"=>[]}, Movie.get_infobox("{{Infobox film\n| starring=''see below''\n}}"))
		assert_equal({"stars"=>[]}, Movie.get_infobox("{{Infobox film\n| starring='''See Below'''\n}}"))
		assert_equal({"stars"=>[]}, Movie.get_infobox("{{Infobox film\n| starring=<small>See Below</small>\n}}"))
		assert_equal({"stars"=>[]}, Movie.get_infobox("{{Infobox film\n| starring=(See Below)\n}}"))
		assert_equal({"stars"=>[]}, Movie.get_infobox("{{Infobox film\n| starring=(''See Below'')\n}}"))
	end

	def test_plain_textify
		assert_equal("AfooB", Movie.plain_textify("A{{ill|foo|bar}}B"))
		assert_equal("A[[target|text]]B", Movie.plain_textify("A[[target|text]]B"))
		assert_equal("AfooB C[[target|text]]D", Movie.plain_textify("A{{ill|foo|bar}}B C[[target|text]]D"))
	end

	def test_split_around_markup
		assert_equal(["a", "b", "c"], Movie.split_around_markup("a|b|c", "|"))
		assert_equal(["a", "[[bbb|B]]", "[[c|C]]", "d"], Movie.split_around_markup("a|[[bbb|B]]|[[c|C]]|d", "|"))
		assert_equal(["a", "{{b|B}}", "c"], Movie.split_around_markup("a|{{b|B}}|c", "|"))
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
		assert_equal("abc", Movie.de_tagify("abc<ref blah blah>def</ref>"))
		assert_equal("abcdef", Movie.de_tagify("abc<ref blah blah />def"))
		assert_equal("abcdef", Movie.de_tagify("abc<!-- comment -->def"))
	end

	def test_expand_brace_commands
		# sort
		assert_equal("[[Black Knight (Monty Python) #Performance difficulty|Richard Burton]]", Movie.plain_textify("{{sort|Burton|[[Black Knight (Monty Python) #Performance difficulty|Richard Burton]]}}"))
		# sortname
		assert_equal("[[John Cleese]]", Movie.plain_textify("{{sortname|John|Cleese}}"))
		assert_equal("[[John Young (actor)|John Young]]", Movie.plain_textify("{{sortname|John|Young|dab=actor}}"))
		assert_equal("Bee Duffell", Movie.plain_textify("{{sortname|Bee|Duffell|nolink=y}}"))
	end

	def test_get_actor_from_line
		assert_equal("Kevin Bacon", Movie.get_actor_from_line("Kevin Bacon as Character Name"))
		assert_equal("Aaa Bbb de Ccc", Movie.get_actor_from_line("Aaa Bbb de Ccc is an actor"))
		assert_equal("Aaa 'Bbb' Ccc", Movie.get_actor_from_line("Aaa 'Bbb' Ccc as Character Name"))
		assert_equal("Aaa Ōsomething", Movie.get_actor_from_line("Aaa Ōsomething lower Upper"))
		assert_equal("Aaa Ásomething", Movie.get_actor_from_line("Aaa Ásomething lower Upper"))
	end

	def test_wikitables
		# trivial one-cell table
		table_helper([["one cell"]],
			"{|",
			"| one cell",
			"|}")

		# ignore the caption
		table_helper([["foo"]],
			"{|",
			"|+ caption",
			"| foo",
			"|}")

		# 2x2 table with || delimeters
		table_helper([["foo", "bar"], ["xxx", "yyy"]],
			"{|",
			"|-",
			"| foo || bar",
			"|-",
			"| xxx || yyy",
			"|-",
			"|}")

		# 2x2 table with one cell per line
		table_helper([["foo", "bar"], ["xxx", "yyy"]],
			"{|",
			"| foo",
			"| bar",
			"|-",
			"| xxx",
			"| yyy",
			"|-",
			"|}")

		# 3x1 table with mixed delimeters
		table_helper([["aaa", "bbb", "ccc"]],
			"{|",
			"|-",
			"| aaa",
			"| bbb || ccc",
			"|-",
			"|}")

		# one-cell table; "|" is not a cell separator
		table_helper([["aaa | bbb"]],
			"{|",
			"|-",
			"| fmt | aaa | bbb",
			"|-",
			"|}")

		# one-cell table; "\n" is not a cell separator
		table_helper([["aa\nbb"]],
			"{|",
			"|-",
			"| aa",
			"bb",
			"|-",
			"|}")

		# 3x3 table with headings
		table_helper([
			["Column heading 1", "Column heading 2", "Column heading 3"],
			["Row heading 1", "Cell 2", "Cell 3"],
			["Row heading A", "Cell B", "Cell C"]],
			'{| border="1"',
			'|+ The caption',
			'! scope="col" | Column heading 1',
			'! scope="col" | Column heading 2',
			'! scope="col" | Column heading 3',
			'|-',
			'! scope="row" | Row heading 1',
			'| Cell 2 || Cell 3',
			'|-',
			'! scope="row" | Row heading A',
			'| Cell B',
			'| Cell C',
			'|}')

		# 3x3 table with headings
		table_helper([
			["Column heading 1", "Column heading 2", "Column heading 3"],
			["Row heading 1", "Cell 2", "Cell 3"],
			["Row heading A", "Cell B", "Cell C"]],
			'{| border="1"',
			'|+ The caption',
			'! Column heading 1 !! Column heading 2 !! Column heading 3',
			'|-',
			'! scope="row" | Row heading 1',
			'| Cell 2 || Cell 3',
			'|-',
			'! scope="row" | Row heading A',
			'| Cell B',
			'| Cell C',
			'|}')

		table_helper([
			[ "× ", "1 ", "2 ", "3" ],
			[ "1", "1", "2", "3" ],
			[ "2", "2", "4", "6" ],
			[ "3", "3", "6", "9" ],
			[ "4", "4", "8", "12" ],
			[ "5", "5", "10", "15" ]],
			'{| class="wikitable" style="text-align: center; width: 200px; height: 200px;"',
			'|+ Multiplication table',
			'|-',
			'! scope="col" | × ',
			'! scope="col" | 1 ',
			'! scope="col" | 2 ',
			'! scope="col" | 3',
			'|-',
			'! scope="row" | 1',
			'| 1 || 2 || 3',
			'|-',
			'! scope="row" | 2',
			'| 2 || 4 || 6',
			'|-',
			'! scope="row" | 3',
			'| 3 || 6 || 9',
			'|-',
			'! scope="row" | 4',
			'| 4 || 8 || 12',
			'|-',
			'! scope="row" | 5',
			'| 5 || 10 || 15',
			'|}')

		# We should ignore all styles
		table_helper([
			[ "abc", "def", "ghi" ],
			[ "jkl", "mno", "pqr" ],
			[ "stu", "vwx", "yz" ]],
			'{| style="background: yellow; color: green"',
			'|-',
			'| abc || def || ghi',
			'|- style="background: red; color: white"',
			'| jkl || mno || pqr',
			'|-',
			'| stu || style="background: silver" | vwx || yz',
			'|}')

		table_helper([
			[ "abc", "def", "ghi" ],
			[ "jkl", "mno", "pqr" ],
			[ "stu", "vwx", "yz" ]],
			'{| style="width: 75%; height: 200px" border="1"',
			'|-',
			'| abc || def || ghi',
			'|- style="height: 100px;"',
			'| jkl || style="width: 200px;" | mno || pqr',
			'|-',
			'| stu || vwx || yz',
			'|}')

		table_helper([
			[ "Name", "Effect", "Games Found In" ],
			[ "Poké Ball", "Regular Poké Ball", "All Versions" ],
			[ "Great Ball", "Better than a Poké Ball", "All Versions" ]],
			'{| border="1" cellpadding="2"',
			'! scope="col" width="50" | Name',
			'! scope="col" width="225" | Effect',
			'! scope="col" width="225" | Games Found In',
			'|-',
			'| Poké Ball || Regular Poké Ball || All Versions',
			'|-',
			'| Great Ball || Better than a Poké Ball || All Versions',
			'|}')

		table_helper([
			[ "This column is 100 points wide", "This column is 200 points wide", "This column is 300 points wide" ],
			[ "blah", "blih", "bluh" ]],
			'{| border="1" cellpadding="2"',
			'|-',
			'| width="100pt" | This column is 100 points wide',
			'| width="200pt" | This column is 200 points wide',
			'| width="300pt" | This column is 300 points wide',
			'|-',
			'| blah || blih || bluh',
			'|}')

		# 
		table_helper([
			[ "Left", "Middle", "Right" ],
			[ "\n[[File:StarIconBronze.png|120px]]", "\n[[File:StarIconGold.png|120px|Caption when mouse-over image]]", "<!--greenish border-->\n[[File:StarIconGreen.png|120px|Green stellar icon]]" ],
			[ "Bronze star", "Gold star", "Green star" ]],
			'{| cellpadding="2" style="border: 1px solid darkgray;"',
			'! width="140" | Left',
			'! width="150" | Middle',
			'! width="130" | Right',
			'|- align="center"',
			'| style="border: 1px solid blue;"|',
			'[[File:StarIconBronze.png|120px]]',
			'| style="border: 1px solid #777777;"|',
			'[[File:StarIconGold.png|120px|Caption when mouse-over image]]',
			'| style="border: 1px solid #22AA55;"|<!--greenish border-->',
			'[[File:StarIconGreen.png|120px|Green stellar icon]]',
			'|- align="center"',
			'|Bronze star || Gold star || Green star',
			'|}')

		table_helper([
			[ "Row heading", "A longer piece of text. Each cell of a table...", "short text" ],
			[ "Row heading", "On each row, of a table, the centering of the text will happen...", "short text" ]],
			'{| border="1" cellpadding="2" width="400"',
			'|- valign="top"',
			'! width="10%" | Row heading',
			'| width="70%" | A longer piece of text. Each cell of a table...',
			'| width="20%" | short text',
			'|- valign="top"',
			'! Row heading',
			'| On each row, of a table, the centering of the text will happen...',
			'| short text',
			'|}')

		# table with spans
		table_helper([
			[ "First header", "Second header" ],
			[ "upper left", "&nbsp;", "\nright side" ],
			[ "lower left", "lower middle" ],
			[ "\ncontent" ]],
			'{| border="1" cellpadding="5" cellspacing="0" align="center"',
			'|+ An example table',
			'|-',
			'! style="background: #efefef;" | First header',
			'! colspan="2" style="background: #ffdead;" | Second header',
			'|-',
			'| upper left',
			'| &nbsp;',
			'| rowspan="2" style="border-bottom: 3px solid grey;" valign="top" |',
			'right side',
			'|-',
			'| style="border-bottom: 3px solid grey;" | lower left',
			'| style="border-bottom: 3px solid grey;" | lower middle',
			'|-',
			'| colspan="3" align="center" |',
			'content',
			'|}')
	end

	def table_helper(expect, *lines)
		wt = WikiTable.new
		lines.each do |line|
			wt.line(line)
		end
		assert_equal(expect, wt.data)
		assert_raises(RuntimeError) { wt.line("foo") }
		wt
	end
end
