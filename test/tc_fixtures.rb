#!/usr/bin/ruby

require 'test/unit'
require '../lib/movie'
require '../lib/parser'

class TestGetCast < Test::Unit::TestCase
	def test_fixtures
		test_helper("Actrius",
			%Q({"title":"Actrius",
			    "cast":["Núria Espert","Rosa Maria Sardà","Anna Lizaran","Mercè Pons"],
			    "directors":["Ventura Pons"],
			    "producers":["Ventura Pons"],
			    "companies":["Canal+ España","Els Films de la Rambla S.A.","Generalitat de Catalunya - Departament de Cultura","Televisión Española","Buena Vista International"],
			    "year":1997}))

		test_helper("Army of Darkness",
			%Q({"title":"Army of Darkness",
			    "cast":["Bruce Campbell","Embeth Davidtz","Marcus Gilbert","Ian Abercrombie","Richard Grove","Timothy Patrick Quill","Michael Earl Reid","Bridget Fonda","Patricia Tallman","Ted Raimi","Angela Featherstone"],
			    "directors":["Sam Raimi"],
			    "producers":["Robert Tapert"],
			    "companies":["Dino De Laurentiis Communications","Renaissance Pictures","Universal Pictures"],
			    "year":1992}))

		test_helper("Batman (1966 film)",
			%Q({"title":"Batman (1966 film)",
			    "cast":["Adam West","Burt Ward","Lee Meriwether","Cesar Romero","Burgess Meredith","Frank Gorshin","Alan Napier","Neil Hamilton","Stafford Repp","Madge Blake","Reginald Denny","Milton Frome","Gil Perkins","Dick Crockett","George Sawaya","Van Williams"],
			    "directors":["Leslie H. Martinson"],
			    "producers":["William Dozier"],
			    "companies":["William Dozier Productions","Greenlawn Productions","20th Century Fox"],
			    "year":1966}))

		test_helper("Batman (1989 film)",
			%Q({"title":"Batman (1989 film)",
			    "cast":["Jack Nicholson","Michael Keaton","Kim Basinger","Robert Wuhl","Pat Hingle","Billy Dee Williams","Michael Gough","Jack Palance","Jerry Hall","Tracey Walter","Lee Wallace","William Hootkins","John Dair","Christopher Fairbank","George Roth","Hugo E. Blick","Charles Roskilly","David Baxt","Sharon Holm","Garrick Hagon","Liza Ross","Adrian Meyers"],
			    "directors":["Tim Burton"],
			    "producers":["Jon Peters","Peter Guber"],
			    "companies":["Warner Bros. Pictures","Guber-Peters Company"],
			    "year":1989}))

		test_helper("Evil Dead II",
			%Q({"title":"Evil Dead II",
			    "cast":["Bruce Campbell","Sarah Berry","Dan Hicks","Kassie Wesley","Richard Domeier","Ted Raimi","Denise Bixler","John Peaks","Lou Hancock","William Preston Robertson"],
			    "directors":["Sam Raimi"],
			    "producers":["Robert Tapert","Alex De Benedetti","Irvin Shapiro"],
			    "companies":["Don Nafia","Renaissance Pictures","Embassy Communications","De Laurentiis Entertainment Group","Palace Pictures"],
			    "year":1987}))

		# ==Cast== is a 2-column table
		skip_test_helper("Four Daughters",
			%Q({"title":"Four Daughters",
			    "cast":["Priscilla Lane","Rosemary Lane","Lola Lane","Gale Page","John Garfield","Jeffrey Lynn","May Robson","Frank McHugh","Claude Rains","Dick Foran","Claude Rains"],
			    "directors":["Michael Curtiz"],
			    "producers":["Hal B. Wallis"],
			    "companies":["Warner Bros."],
			    "year":1938}))

		test_helper("Monty Python and the Holy Grail",
			%Q({"title":"Monty Python and the Holy Grail",
			    "cast":["Graham Chapman","John Cleese","Terry Gilliam","Eric Idle","Terry Jones","Michael Palin","Connie Booth","Carol Cleveland","Neil Innes","Bee Duffell","John Young","Rita Davies","Avril Stewart","Sally Kinghorn","Mark Zycon","Sandy Johnson","Julian Doyle","Richard Burton"],
			    "companies":["Python (Monty) Pictures","Michael White Productions","National Film Trustee Company","EMI Films"],
			    "year":1975}))

		# ==Cast== is a table
		# also, Paul Butcher, Jr.
		skip_test_helper("My Neighbor Totoro",
			%Q({"title":"My Neighbor Totoro",
			    "cast":["Chika Sakamoto","Noriko Hidaka","Hitoshi Takagi","Lisa Michelson","Dakota Fanning","Cheryl Chase","Elle Fanning","Shigesato Itoi","Greg Snegoff","Tim Daly","Sumi Shimamoto","Alexandra Kenworthy","Lea Salonga","Frank Welker","Toshiyuki Amagasa","Kenneth Hartman","Paul Butcher, Jr.","Tanie Kitabayashi","Natalie Core","Pat Carroll","Naoki Tatsuta","Carl Macek","Frank Welker","Chie Kojiro","Brianne Siddall","Hiroko Maruyama","Melanie MacQueen","Kath Soucie","Masashi Hirose","Steve Kramer","Peter Renaday","Machiko Washio","Edie Mirman","Tress MacNeille","Reiko Suzuki","Russi Taylor","Daiki Nakamura","Kerrigan Mahan","Yuko Mizutani","Lara Cody","Bridget Hoffman","Kath Soucie","Tomomichi Nishimura","Doug Stone"],
			    "directors":["Hayao Miyazaki"],
			    "producers":["Toru Hara"],
			    "companies":["Studio Ghibli","Toho"],
			    "year":1988}))

		test_helper("Original Sin (2001 film)",
			%Q({"title":"Original Sin (2001 film)",
			    "cast":["Antonio Banderas","Angelina Jolie","Thomas Jane","Jack Thompson","Gregory Itzin","Pedro Armendáriz, Jr.","James Haven","Allison Mackie","Joan Pringle","Cordelia Richards","Pedro Armendariz","Mario Ivan Martinez","Harry Porter","Fernando Torre Lapham","Shaula Vega","Lisa Owen","Daniel Martínez","Farnesio De Bernal","Nitzi Arellano","Roger Cudney","Adrian Makala","Francis Laborial","Derek Rojo","Abraham Stavans","Julio Bracho"],
			    "directors":["Michael Cristofer"],
			    "producers":["Denise Di Novi","Kate Guinzberg","Carol Lees"],
			    "companies":["Hyde Park Entertainment","Metro–Goldwyn–Mayer","MGM Distribution Co."],
			    "year":2001}))

		test_helper("Random Harvest (film)",
			%Q({"title":"Random Harvest (film)",
			    "cast":["Ronald Colman","Greer Garson","Philip Dorn","Susan Peters","Henry Travers","Reginald Owen","Bramwell Fletcher","Rhys Williams","Una O'Connor","Aubrey Mather","Margaret Wycherly","Arthur Margetson","Melville Cooper","Alan Napier","Jill Esmond","Ivan F. Simpson","Ann Richards","Norma Varden","David Cavendish","Marie De Becker","Charles Waldron","Elisabeth Risdon"],
			    "directors":["Mervyn LeRoy"],
			    "producers":["Sidney Franklin"],
			    "companies":["Metro-Goldwyn-Mayer","Loew's Inc."],
			    "year":1942}))

		# ==Cast== in a table
		skip_test_helper("Roman Holiday",
			%Q({"title":"Roman Holiday",
			    "cast":["Gregory Peck","Audrey Hepburn","Eddie Albert","Hartley Power","Harcourt Williams","Margaret Rawlings","Tullio Carminati","Paolo Carlini","Claudio Ermelli","Paola Borboni","Laura Solari","Alfredo Rizzo","Gorella Gori"],
			    "directors":["William Wyler"],
			    "producers":["William Wyler"],
			    "companies":["Paramount Pictures"],
			    "year":1953}))

		test_helper("Spirited Away",
			%Q({"title":"Spirited Away",
			    "cast":["Rumi Hiiragi","Miyu Irino","Mari Natsuki","Takeshi Naito","Yasuko Sawaguchi","Tsunehiko Kamijō","Takehiko Ono","Bunta Sugawara","Daveigh Chase","Jason Marsden","Suzanne Pleshette","David Ogden Stiers","Yoomi Tamai","Susan Egan","Paul Eiding","John Ratzenberger","Akio Nakamura","Bob Bergen","Tatsuya Gashūin","Yō Ōizumi","Rodger Bumpass","Ryūnosuke Kamiki","Tara Strong","Takashi Naitō","Michael Chiklis","Lauren Holly","Koba Hayashi","Jim Ward","Ken Yasuda","Jack Angel"],
			    "directors":["Hayao Miyazaki"],
			    "producers":["Toshio Suzuki"],
			    "companies":["Studio Ghibli","Toho"],
			    "year":2001}))

		test_helper("Strategic Air Command (film)",
			%Q({"title":"Strategic Air Command (film)",
			    "cast":["James Stewart","June Allyson","Frank Lovejoy","Bruce Bennett","Barry Sullivan","Alex Nicol","Jay C. Flippen","Harry Morgan"],
			    "directors":["Anthony Mann"],
			    "producers":["Samuel J. Briskin"],
			    "companies":["Paramount Pictures"],
			    "year":1955}))

		test_helper("Taxi Driver",
			%Q({"title":"Taxi Driver",
			    "cast":["Robert De Niro","Jodie Foster","Albert Brooks","Harvey Keitel","Leonard Harris","Peter Boyle","Cybill Shepherd","Steven Prince","Ashley Peidl"],
			    "directors":["Martin Scorsese"],
			    "producers":["Julia Phillips","Michael Phillips"],
			    "companies":["Bill/Phillips Productions","Italo/Judeo Productions","Columbia Pictures"],
			    "year":1976}))

		# stars, directors, producers separated by the word "and"
		# "(associate producer)" on its own line is not a third producer.
		# ==Cast== is two tables, the first of which has two columns
		# ===Unbilled=== sub of ==Cast== is a comma-separated English sentence
		skip_test_helper("The Good Earth (film)",
			%Q({"title":"The Good Earth (film)",
			    "cast":["Paul Muni","Luise Rainer","Tilly Losch","Charley Grapewin","Walter Connolly","Jessie Ralph","Soo Yong","Keye Luke","Roland Lui","Suzanna Kim","Ching Wah Lee","Harold Huber","Olaf Hytten","William Law","Mary Wong","Charles Middleton","Chester Gan","Richard Loo","Kam Tong","Victor Sen Yung","Philip Ahn","Bessie Loo","Clarence Lung","Sammee Tong","Richard Daniel Cazares"],
			    "directors":["Sidney Franklin","Victor Fleming","Gustav Machatý"],
			    "producers":["Irving Thalberg","Albert Lewin"],
			    "companies":["Metro-Goldwyn-Mayer"],
			    "year":1937}))

		test_helper("The Life of Emile Zola",
			%Q({"title":"The Life of Emile Zola",
			    "cast":["Paul Muni","Gloria Holden","Gale Sondergaard","Joseph Schildkraut","Donald Crisp","Erin O'Brien-Moore","John Litel","Henry O'Neill","Morris Carnovsky","Louis Calhern","Ralph Morgan","Robert Barrat","Vladimir Sokoloff","Grant Mitchell","Harry Davenport","Robert Warwick","Charles Richman","Gilbert Emery","Walter Kingsford","Paul Everton","Montagu Love","Frank Sheridan","Lumsden Hare","Marcia Mae Jones","Florence Roberts","Dickie Moore","Rolla Gourvitch"],
			    "directors":["William Dieterle"],
			    "producers":["Henry Blanke"],
			    "companies":["Warner Bros."],
			    "year":1937}))

		# producer line has "/ ..."
		skip_test_helper("The Company of Strangers",
			%Q({"title":"The Company of Strangers",
			    "cast":["Alice Diabo","Constance Garneau"],
			    "directors":["Cynthia Scott"],
			    "producers":["David Wilson"],
			    "companies":["First Run Features","Castle Hill Productions","National Film Board of Canada"],
			    "year":1990}))

		test_helper("48 Hrs.",
			%Q({"title":"48 Hrs.",
			    "cast":["Nick Nolte","Eddie Murphy","James Remar","David Patrick Kelly","Sonny Landham","Brion James","Annette O'Toole","Frank McRae","Kerry Sherman","Jonathan Banks","Margot Rose","Denise Crosby","Olivia Brown"],
			    "directors":["Walter Hill"],
			    "producers":["Lawrence Gordon","Joel Silver"],
			    "companies":["Paramount Pictures"],
			    "year":1982}))

		test_helper("Batman Forever",
			%Q({"title":"Batman Forever",
			    "cast":["Val Kilmer","Tommy Lee Jones","Jim Carrey","Nicole Kidman","Michael Gough","Pat Hingle","Chris O'Donnell","Drew Barrymore","Debi Mazar","Elizabeth Sanders","Joe Grifasi","Ofer Samra","René Auberjonois"],
			    "directors":["Joel Schumacher"],
			    "producers":["Tim Burton","Peter MacGregor-Scott"],
			    "companies":["Warner Bros. Pictures"],
			    "year":1995}))
	end

	def test_tv_shows
		# These are TV shows, so they don't get parsed as movies.
		test_helper("Hercules: The Legendary Journeys", "")
		test_helper("Matlock (TV series)", "")
		test_helper("The Dukes of Hazzard", "")
		test_helper("Twin Peaks", "")
	end

	def test_people
		# These are people, so they don't get parsed as movies.
		test_helper("Werner Herzog", "")
	end

private
	def test_helper(fn, expect_json, ignore_mismatch=false)
		File.open("fixtures/#{fn}.xml") do |fp|
			parser = Parser.new do |movie|
				actual_json = movie.to_json
				expect_json = expect_json.gsub(/\n\s*/, '')
				if ignore_mismatch
					puts "Known-broken test #{fn}: " + ((expect_json == actual_json) ? "FIXED" : "still broken")
				else
					assert_equal(expect_json, actual_json)
				end
			end
			Ox.sax_parse(parser, fp, :skip => :skip_none)
		end
	end

	def skip_test_helper(fn, expect_json)
		test_helper(fn, expect_json, true)
	end
end
