#!/usr/bin/ruby

require 'test/unit'
require '../lib/movie'
require '../lib/parser'

class TestGetCast < Test::Unit::TestCase
	def test_fixtures
		test_helper("Actrius",
			%Q({"title":"Actrius",
			    "cast":["[[Núria Espert]]","[[Rosa Maria Sardà]]","[[Anna Lizaran]]","[[Mercè Pons]]"],
			    "directors":["[[Ventura Pons]]"],
			    "producers":["[[Ventura Pons]]"],
			    "companies":["[[Canal+|Canal+ España]]","Els Films de la Rambla S.A.","[[Generalitat de Catalunya|Generalitat de Catalunya - Departament de Cultura]]","[[Televisión Española]]","[[Buena Vista International]]"],
			    "year":1997}))

		test_helper("Army of Darkness",
			%Q({"title":"Army of Darkness",
			    "cast":["[[Bruce Campbell]]","[[Embeth Davidtz]]","[[Marcus Gilbert (actor)|Marcus Gilbert]]","[[Ian Abercrombie]]","Richard Grove","Timothy Patrick Quill","Michael Earl Reid","[[Bridget Fonda]]","[[Patricia Tallman]]","[[Ted Raimi]]","[[Angela Featherstone]]"],
			    "directors":["[[Sam Raimi]]"],
			    "producers":["[[Robert Tapert]]"],
			    "companies":["[[Dino De Laurentiis|Dino De Laurentiis Communications]]","[[Renaissance Pictures]]","[[Universal Studios|Universal Pictures]]"],
			    "year":1992}))

		test_helper("Batman (1966 film)",
			%Q({"title":"Batman (1966 film)",
			    "cast":["[[Adam West]]","[[Burt Ward]]","[[Lee Meriwether]]","[[Cesar Romero]]","[[Burgess Meredith]]","[[Frank Gorshin]]","[[Alan Napier]]","[[Neil Hamilton (actor)|Neil Hamilton]]","[[Stafford Repp]]","[[Madge Blake]]","[[Reginald Denny (actor)|Reginald Denny]]","[[Milton Frome]]","[[Gil Perkins]]","[[Dick Crockett]]","[[George Sawaya]]","[[Van Williams]]"],
			    "directors":["[[Leslie H. Martinson]]"],
			    "producers":["[[William Dozier]]"],
			    "companies":["William Dozier Productions","Greenlawn Productions","[[20th Century Fox]]"],
			    "year":1966}))

		test_helper("Batman (1989 film)",
			%Q({"title":"Batman (1989 film)",
			    "cast":["[[Jack Nicholson]]","[[Michael Keaton]]","[[Kim Basinger]]","[[Robert Wuhl]]","[[Pat Hingle]]","[[Billy Dee Williams]]","[[Michael Gough]]","[[Jack Palance]]","[[Jerry Hall]]","[[Tracey Walter]]","[[Lee Wallace (actor)|Lee Wallace]]","[[William Hootkins]]","[[John Dair]]","[[Christopher Fairbank]]","George Roth","[[Hugo Blick|Hugo E. Blick]]","Charles Roskilly","David Baxt","Sharon Holm","[[Garrick Hagon]]","Liza Ross","Adrian Meyers"],
			    "directors":["[[Tim Burton]]"],
			    "producers":["[[Jon Peters]]","[[Peter Guber]]"],
			    "companies":["[[Warner Bros. Pictures]]","Guber-Peters Company"],
			    "year":1989}))

		test_helper("Evil Dead II",
			%Q({"title":"Evil Dead II",
			    "cast":["[[Bruce Campbell]]","Sarah Berry","[[Dan Hicks (actor)|Dan Hicks]]","[[Kassie DePaiva|Kassie Wesley]]","Richard Domeier","[[Ted Raimi]]","Denise Bixler","John Peaks","Lou Hancock","William Preston Robertson"],
			    "directors":["[[Sam Raimi]]"],
			    "producers":["[[Robert Tapert]]","Alex De Benedetti","[[Irvin Shapiro]]"],
			    "companies":["Don Nafia","[[Renaissance Pictures]]","[[Embassy Communications]]","[[De Laurentiis Entertainment Group]]","[[Palace Pictures]]"],
			    "year":1987}))

		# Rosemary Lane and Lola Lane appear twice, with different link text.
		test_helper("Four Daughters",
			%Q({"title":"Four Daughters",
			    "cast":["[[Priscilla Lane]]","[[Rosemary Lane (actress)|Rosemary Lane]]","[[Lola Lane]]","[[Gale Page]]","[[John Garfield]]","[[Lane Sisters|Rosemary Lane]]","[[Jeffrey Lynn]]","[[Lane Sisters|Lola Lane]]","[[May Robson]]","[[Frank McHugh]]","[[Claude Rains]]","[[Dick Foran]]"],
			    "directors":["[[Michael Curtiz]]"],
			    "producers":["[[Hal B. Wallis]]"],
			    "companies":["[[Warner Bros.]]"],
			    "year":1938}))

		test_helper("Monty Python and the Holy Grail",
			%Q({"title":"Monty Python and the Holy Grail",
			    "cast":["[[Graham Chapman]]","[[John Cleese]]","[[Terry Gilliam]]","[[Eric Idle]]","[[Terry Jones]]","[[Michael Palin]]","[[Connie Booth]]","[[Carol Cleveland]]","[[Neil Innes]]","Bee Duffell","[[John Young (actor)|John Young]]","Rita Davies","Avril Stewart","Sally Kinghorn","Mark Zycon","[[Sandy Johnson (director)|Sandy Johnson]]","[[Julian Doyle (filmmaker)|Julian Doyle]]","[[Black Knight (Monty Python) #Performance difficulty|Richard Burton]]"],
			    "directors":["[[Terry Gilliam]]","[[Terry Jones]]"],
			    "producers":["[[Mark Forstater]]","[[Michael White (producer)|Michael White]]"],
			    "companies":["[[Python (Monty) Pictures]]","Michael White Productions","National Film Trustee Company","[[EMI Films]]"],
			    "year":1975}))

		test_helper("My Neighbor Totoro",
			%Q({"title":"My Neighbor Totoro",
			    "cast":["[[Chika Sakamoto]]","[[Noriko Hidaka]]","[[Hitoshi Takagi]]","[[Lisa Michelson]]","[[Dakota Fanning]]","[[Cheryl Chase]]","[[Elle Fanning]]","[[Shigesato Itoi]]","[[Gregory Snegoff|Greg Snegoff]]","[[Tim Daly]]","[[Sumi Shimamoto]]","[[Alexandra Kenworthy]]","[[Lea Salonga]]","[[Frank Welker]]","Toshiyuki Amagasa","Kenneth Hartman","[[Paul Butcher, Jr.|Paul Butcher]]","[[Tanie Kitabayashi]]","Natalie Core","[[Pat Carroll (actress)|Pat Carroll]]","[[Naoki Tatsuta]]","[[Carl Macek]]","[[Chie Kojiro]]","[[Brianne Siddall]]","Hiroko Maruyama","Melanie MacQueen","[[Kath Soucie]]","[[Masashi Hirose]]","[[Steve Kramer (actor)|Steve Kramer]]","[[Peter Renaday]]","[[Machiko Washio]]","[[Edie Mirman]]","[[Tress MacNeille]]","[[Reiko Suzuki]]","[[Russi Taylor]]","[[Daiki Nakamura]]","[[Kerrigan Mahan]]","[[Yuko Mizutani]]","[[Lara Cody]]","[[Bridget Hoffman]]","[[Tomomichi Nishimura]]","[[Doug Stone (voice actor)|Doug Stone]]"],
			    "directors":["[[Hayao Miyazaki]]"],
			    "producers":["Toru Hara"],
			    "companies":["[[Studio Ghibli]]","[[Toho]]"],
			    "year":1988}))

		test_helper("Original Sin (2001 film)",
			%Q({"title":"Original Sin (2001 film)",
			    "cast":["[[Antonio Banderas]]","[[Angelina Jolie]]","[[Thomas Jane]]","[[Jack Thompson (actor)|Jack Thompson]]","[[Gregory Itzin]]","[[Pedro Armendáriz, Jr.]]","[[James Haven]]","[[Allison Mackie]]","[[Joan Pringle]]","[[Cordelia Richards]]","[[Pedro Armendariz]]","[[Mario Ivan Martinez]]","[[Harry Porter]]","[[Fernando Torre Lapham]]","[[Shaula Vega]]","[[Lisa Owen]]","[[Daniel Martínez (actor)|Daniel Martínez]]","[[Farnesio De Bernal]]","[[Nitzi Arellano]]","[[Roger Cudney]]","[[Adrian Makala]]","[[Francis Laborial]]","[[Derek Rojo]]","[[Abraham Stavans]]","[[Julio Bracho]]"],
			    "directors":["[[Michael Cristofer]]"],
			    "producers":["[[Denise Di Novi]]","Kate Guinzberg","Carol Lees"],
			    "companies":["[[Hyde Park Entertainment]]","[[Metro–Goldwyn–Mayer]]","[[MGM Distribution Co.]]"],
			    "year":2001}))

		test_helper("Random Harvest (film)",
			%Q({"title":"Random Harvest (film)",
			    "cast":["[[Ronald Colman]]","[[Greer Garson]]","[[Philip Dorn]]","[[Susan Peters]]","[[Henry Travers]]","[[Reginald Owen]]","[[Bramwell Fletcher]]","[[Rhys Williams (Welsh-American actor)|Rhys Williams]]","[[Una O'Connor (actress)|Una O'Connor]]","[[Aubrey Mather]]","[[Margaret Wycherly]]","[[Arthur Margetson]]","[[Melville Cooper]]","[[Alan Napier]]","[[Jill Esmond]]","[[Ivan F. Simpson]]","[[Ann Richards (actress)|Ann Richards]]","[[Norma Varden]]","[[David Cavendish]]","[[Marie De Becker]]","[[Charles Waldron]]","[[Elisabeth Risdon]]"],
			    "directors":["[[Mervyn LeRoy]]"],
			    "producers":["[[Sidney Franklin (director)|Sidney Franklin]]"],
			    "companies":["[[Metro-Goldwyn-Mayer]]","Loew's Inc."],
			    "year":1942}))

		test_helper("Roman Holiday",
			%Q({"title":"Roman Holiday",
			    "cast":["[[Gregory Peck]]","[[Audrey Hepburn]]","[[Eddie Albert]]","[[Hartley Power]]","[[Harcourt Williams]]","[[Margaret Rawlings]]","[[Tullio Carminati]]","[[Paolo Carlini]]","[[Claudio Ermelli]]","[[Paola Borboni]]","[[Laura Solari]]","[[Alfredo Rizzo]]","[[Gorella Gori]]"],
			    "directors":["[[William Wyler]]"],
			    "producers":["[[William Wyler]]"],
			    "companies":["[[Paramount Pictures]]"],
			    "year":1953}))

		test_helper("Spirited Away",
			%Q({"title":"Spirited Away",
			    "cast":["[[Rumi Hiiragi]]","[[Miyu Irino]]","[[Mari Natsuki]]","Takeshi Naito","[[Yasuko Sawaguchi]]","[[Tsunehiko Kamijō]]","[[Takehiko Ono]]","[[Bunta Sugawara]]","[[Daveigh Chase]]","[[Jason Marsden]]","[[Suzanne Pleshette]]","[[David Ogden Stiers]]","[[Yoomi Tamai]]","[[Susan Egan]]","[[Paul Eiding]]","[[John Ratzenberger]]","[[Akio Nakamura]]","[[Bob Bergen]]","[[Tatsuya Gashūin]]","[[Yo Oizumi|Yō Ōizumi]]","[[Rodger Bumpass]]","[[Ryunosuke Kamiki|Ryūnosuke Kamiki]]","[[Tara Strong]]","[[Takashi Naitō]]","[[Michael Chiklis]]","[[Lauren Holly]]","[[Koba Hayashi]]","[[Jim Ward (voice actor)|Jim Ward]]","[[Ken Yasuda (actor)|Ken Yasuda]]","[[Jack Angel]]"],
			    "directors":["[[Hayao Miyazaki]]"],
			    "producers":["[[Toshio Suzuki (producer)|Toshio Suzuki]]"],
			    "companies":["[[Studio Ghibli]]","[[Toho]]"],
			    "year":2001}))

		test_helper("Strategic Air Command (film)",
			%Q({"title":"Strategic Air Command (film)",
			    "cast":["[[James Stewart]]","[[June Allyson]]","[[Frank Lovejoy]]","[[Bruce Bennett]]","[[Barry Sullivan (actor)|Barry Sullivan]]","[[Alex Nicol]]","[[Jay C. Flippen]]","[[Harry Morgan]]"],
			    "directors":["[[Anthony Mann]]"],
			    "producers":["[[Samuel J. Briskin]]"],
			    "companies":["[[Paramount Pictures]]"],
			    "year":1955}))

		test_helper("Taxi Driver",
			%Q({"title":"Taxi Driver",
			    "cast":["[[Robert De Niro]]","[[Jodie Foster]]","[[Albert Brooks]]","[[Harvey Keitel]]","[[Leonard Harris (actor)|Leonard Harris]]","[[Peter Boyle]]","[[Cybill Shepherd]]","Steven Prince","[[Ashley Peidl]]"],
			    "directors":["[[Martin Scorsese]]"],
			    "producers":["[[Julia Phillips]]","[[Michael Phillips (producer)|Michael Phillips]]"],
			    "companies":["Bill/Phillips Productions","Italo/Judeo Productions","[[Columbia Pictures]]"],
			    "year":1976}))

		# stars, directors, producers separated by the word "and"
		# "(associate producer)" on its own line is not a third producer.
		# ==Cast== is two tables, the first of which has two columns
		# ===Unbilled=== sub of ==Cast== is a comma-separated English sentence
		skip_test_helper("The Good Earth (film)",
			%Q({"title":"The Good Earth (film)",
			    "cast":["[[Paul Muni]]","[[Luise Rainer]]","[[Tilly Losch]]","[[Charley Grapewin]]","[[Walter Connolly]]","[[Jessie Ralph]]","[[Soo Yong]]","[[Keye Luke]]","[[Roland Lui]]","[[Suzanna Kim]]","[[Ching Wah Lee]]","[[Harold Huber]]","[[Olaf Hytten]]","[[William Law]]","[[Mary Wong]]","[[Charles Middleton]]","[[Chester Gan]]","[[Richard Loo]]","[[Kam Tong]]","[[Victor Sen Yung]]","[[Philip Ahn]]","[[Bessie Loo]]","[[Clarence Lung]]","[[Sammee Tong]]","[[Richard Daniel Cazares]]"],
			    "directors":["[[Sidney Franklin]]","[[Victor Fleming]]","[[Gustav Machatý]]"],
			    "producers":["[[Irving Thalberg]]","[[Albert Lewin]]"],
			    "companies":["[[Metro-Goldwyn-Mayer]]"],
			    "year":1937}))

		test_helper("The Life of Emile Zola",
			%Q({"title":"The Life of Emile Zola",
			    "cast":["[[Paul Muni]]","[[Gloria Holden]]","[[Gale Sondergaard]]","[[Joseph Schildkraut]]","[[Donald Crisp]]","[[Erin O'Brien-Moore]]","[[John Litel]]","[[Henry O'Neill]]","[[Morris Carnovsky]]","[[Louis Calhern]]","[[Ralph Morgan]]","[[Robert Barrat]]","[[Vladimir Sokoloff]]","[[Grant Mitchell (actor)|Grant Mitchell]]","[[Harry Davenport (actor)|Harry Davenport]]","[[Robert Warwick]]","[[Charles Richman (actor)|Charles Richman]]","[[Gilbert Emery]]","[[Walter Kingsford]]","Paul Everton","[[Montagu Love]]","[[Frank Sheridan]]","[[Lumsden Hare]]","[[Marcia Mae Jones]]","[[Florence Roberts]]","[[Dickie Moore (actor)|Dickie Moore]]","Rolla Gourvitch"],
			    "directors":["[[William Dieterle]]"],
			    "producers":["[[Henry Blanke]]"],
			    "companies":["[[Warner Bros.]]"],
			    "year":1937}))

		test_helper("The Company of Strangers",
			%Q({"title":"The Company of Strangers",
			    "cast":["Alice Diabo","Constance Garneau"],
			    "directors":["[[Cynthia Scott]]"],
			    "producers":["[[David Wilson (producer)|David Wilson]]"],
			    "companies":["[[First Run Features]]","[[Castle Hill Productions]]","National Film Board of Canada"],
			    "year":1990}))

		test_helper("48 Hrs.",
			%Q({"title":"48 Hrs.",
			    "cast":["[[Nick Nolte]]","[[Eddie Murphy]]","[[James Remar]]","[[David Patrick Kelly]]","[[Sonny Landham]]","[[Brion James]]","[[Annette O'Toole]]","[[Frank McRae]]","[[Kerry Sherman]]","[[Jonathan Banks]]","[[Margot Rose]]","[[Denise Crosby]]","[[Olivia Brown]]"],
			    "directors":["[[Walter Hill (director)|Walter Hill]]"],
			    "producers":["[[Lawrence Gordon (producer)|Lawrence Gordon]]","[[Joel Silver]]"],
			    "companies":["[[Paramount Pictures]]"],
			    "year":1982}))

		test_helper("Batman Forever",
			%Q({"title":"Batman Forever",
			    "cast":["[[Val Kilmer]]","[[Tommy Lee Jones]]","[[Jim Carrey]]","[[Nicole Kidman]]","[[Michael Gough]]","[[Pat Hingle]]","[[Chris O'Donnell]]","[[Drew Barrymore]]","[[Debi Mazar]]","[[Elizabeth Sanders]]","[[Joe Grifasi]]","[[Ofer Samra]]","[[René Auberjonois]]"],
			    "directors":["[[Joel Schumacher]]"],
			    "producers":["[[Tim Burton]]","[[Peter MacGregor-Scott]]"],
			    "companies":["[[Warner Bros. Pictures]]"],
			    "year":1995}))

		# broken: Dominic Savage played young Bullingdon, is credited with a "**" indented bulleted list.
		# Diana Koerner is listed with links to "Diana Koerner" (stars list) and "Diana Körner" (cast section)
		test_helper("Barry Lyndon",
			%Q({"title":"Barry Lyndon",
			    "cast":["[[Ryan O'Neal]]","[[Marisa Berenson]]","[[Patrick Magee (actor)|Patrick Magee]]","[[Hardy Krüger]]","[[Diana Koerner]]","[[Gay Hamilton]]","[[Michael Hordern]]","[[Godfrey Quigley]]","[[Steven Berkoff]]","[[Marie Kean]]","[[Murray Melvin]]","[[Frank Middlemass]]","[[Leon Vitali]]","[[Leonard Rossiter]]","[[André Morell]]","[[Anthony Sharp]]","[[Philip Stone]]","[[David Morley (musician)|David Morley]]","[[Diana Körner|Diana Koerner]]","[[Arthur O'Sullivan]]","[[Billy Boyle]]","[[Jonathan Cecil]]","[[Peter Cellier]]","[[Geoffrey Chater]]","[[Wolf Kahler]]","[[Liam Redmond]]","[[Roger Booth (actor)|Roger Booth]]","[[Ferdy Mayne]]","[[John Sharp (actor)|John Sharp]]","[[Pat Roach]]","[[Hans Meyer (actor)|Hans Meyer]]"],
			    "directors":["[[Stanley Kubrick]]"],
			    "producers":["[[Stanley Kubrick]]"],
			    "companies":["[[Hawk Films]]","Peregrine Productions","[[Warner Bros.]]"],
			    "year":1975}))

		test_helper("Rocky",
			%Q({"title":"Rocky",
			    "cast":["[[Sylvester Stallone]]","[[Talia Shire]]","[[Burt Young]]","[[Carl Weathers]]","[[Burgess Meredith]]","[[Thayer David]]","[[Joe Spinell]]","[[Tony Burton]]","[[Pedro Lovell]]"],
			    "directors":["[[John G. Avildsen]]"],
			    "producers":["[[Irwin Winkler]]","[[Robert Chartoff]]"],
			    "companies":["Chartoff-Winkler Productions","[[United Artists]]"],
			    "year":1976}))

		# Two on a line: Actor as Character and Actor as Character
		# Two first names for a last name: Benjamin and Julie Newmar
		# Bulleted lists with "* '''Character Name''': Actor Name ..."
		skip_test_helper("Seven Brides for Seven Brothers",
			%Q({"title":"Seven Brides for Seven Brothers",
			    "cast":["Howard Keel","Jane Powell","Jeff Richards","Matt Mattox","Marc Platt","Jacques d'Amboise","Tommy Rall","Russ Tamblyn","Julie Newmar","Ruta Lee","Norma Doggett","Virginia Gibson","Betty Carr","Nancy Kilgas","Ian Wolfe","Marjorie Wood","Russell Simpson","Howard Petrie","Benjamin Newmar","Julie Newmar","Daniel Doggett","Ephraim Gibson"],
			    "directors":["Stanley Donen"],
			    "producers":["Jack Cummings"],
			    "companies":["Metro-Goldwyn-Mayer","Loew's, Inc."],
			    "year":1954}))

		# "Actor Name ''as Character Name''" in table cells
		# Two actors for the same character, separated by <br>
		skip_test_helper("The Castle of Cagliostro",
			%Q({"title":"The Castle of Cagliostro",
			    "cast":["[[Yasuo Yamada]]","[[Eiko Masuyama]]","[[Kiyoshi Kobayashi]]","[[Makio Inoue]]","[[Goro Naya]]","[[Sumi Shimamoto]]","[[Tarō Ishida]]","[[Robert Bergen]]","[[Sean Barker]]","[[Joan-Carol O'Connell]]","[[Barbara Goodson]]","[[Ruby Marlowe]]","[[Michael McConnohie]]","[[Sparky Thornton]]","[[Gorō Naya]]","[[David Povall]]","[[Dougary Grant]]","[[Steve Bulen"Ivan Buckley]]","[[Edie Mirman]]","[[Dorothy Melendrez]]","[[Ichirō Nagai]]","[[Jeff Winkless]]","[[Richard Barnes]]","[[Steve Kramer]]","[[Michael Gregory]]","[[Kōhei Miyauchi]]","[[Mike Reynolds]]","[[Gil Starberry]]","[[Tadamichi Tsuneizumi]]","[[Kirk Thornton]]","[[Marlon Mann]]","[[Shōzō Hirabayashi]]","[[Jeff Winkless]]","[[G. Gordon Baer]]","[[Juji Matsuda]]","[[Kerrigan Mahan]]","[[James Lyon]]","[[Kinpei Azusa]]","[[Kirk Thornton]]","[[Alfred Thor]]","[[Yoko Yamaoka]]","[[Julie Donald]]","[[Bambi Darro]]"]
			    "directors":["[[Hayao Miyazaki]]"],
			    "producers":["[[Tetsuo Katayama]]"],
			    "companies":["[[Tokyo Movie Shinsha]]","[[Toho]]"],
			    "year":1979}))

		test_helper("Charly",
			%Q({"title":"Charly",
			    "cast":["[[Cliff Robertson]]","[[Claire Bloom]]","[[Leon Janney]]","[[Lilia Skala]]","[[Dick Van Patten]]","[[Ruth White (actress)|Ruth White]]","Edward McNally","[[Barney Martin]]","William Dwyer","Dan Morgan"],
			    "directors":["[[Ralph Nelson]]"],
			    "producers":["[[Ralph Nelson]]"],
			    "companies":["[[ABC Motion Pictures]]","Robertson and Associates","Selmur Productions","[[Cinerama Releasing Corporation]]"],
			    "year":1968}))

		test_helper("Midnight Cowboy",
			%Q({"title":"Midnight Cowboy",
			    "cast":["[[Dustin Hoffman]]","[[Jon Voight]]","[[Sylvia Miles]]","[[John McGiver]]","[[Brenda Vaccaro]]","[[Barnard Hughes]]","[[Ruth White (actress)|Ruth White]]","[[Jennifer Salt]]","[[Gilman Rankin]]","[[Georgann Johnson]]","[[Anthony Holland (actor)|Anthony Holland]]","[[Bob Balaban]]"],
			    "directors":["[[John Schlesinger]]"],
			    "producers":["[[Jerome Hellman]]"],
			    "companies":["Jerome Hellman Productions","[[United Artists]]"],
			    "year":1969}))

		test_helper("X-Men: First Class",
			%Q({"title":"X-Men: First Class",
			    "cast":["[[James McAvoy]]","[[Michael Fassbender]]","[[Rose Byrne]]","[[January Jones]]","[[Oliver Platt]]","[[Kevin Bacon]]","[[Laurence Belcher]]","[[Bill Milner]]","[[Jennifer Lawrence]]","[[Morgan Lily]]","[[Rebecca Romijn]]","[[Nicholas Hoult]]","[[Jason Flemyng]]","[[Lucas Till]]","[[Edi Gathegi]]","[[Caleb Landry Jones]]","[[Zoë Kravitz]]","[[Matt Craven]]","[[Álex González (actor)|Álex González]]","[[Rade Šerbedžija]]","[[Glenn Morshower]]"],
			    "directors":["[[Matthew Vaughn]]"],
			    "producers":["[[Lauren Shuler Donner]]","[[Bryan Singer]]","[[Simon Kinberg]]","[[Gregory Goodman]]"],
			    "companies":["[[Marvel Entertainment]]","[[Lauren Shuler Donner|The Donners' Company]]","[[Bad Hat Harry Productions]]","[[Dune Entertainment]]","[[Ingenious Media|Ingenious Film Partners]]","[[20th Century Fox]]"],
			    "year":2011}))

		# stars=''see below''
		# cast is a bulleted list contained within a table
		#  - this is the only article in Wikipedia with that arrangement, not really worth the special case
		skip_test_helper("1920 (film series)",
			%Q({"title":"1920 (film series)",
			    "cast":["[[Rajneesh Duggal]]","[[Adah Sharma]]","[[Anjori Alagh]]","[[Indraneil Sengupta]]","[[Raj Zutshi]]","[[Sri Vallabh Vyas]]","[[Vipin Sharma]]","[[Rakhi Sawant]]","[[Aftab Shivdasani]]","[[Tia Bajpai]]","[[Sharad Kelkar]]","[[Vidya Malvade]]","[[Vicky Ahuja as Bankimlal]]","[[Sharman Joshi]]","[[Meera Chopra]]","[[Vishal Karwal]]","[[Gajendra Chauhan]]","[[Meenal Kapoor as Witch]]","[[Sushmita Mukherjee]]","[[Karan Kundra]]","[[Zareen Khan]]","[[Vikram Bhatt]]"],
			    "directors":["[[Vikram Bhatt]]","[[Bhushan Patel]]","[[Tinu Suresh Desai]]"],
			    "producers":["[[Surendra Sharma]]","[[Bhagwati Gabrani]]","[[Amita Bisnoi]]","[[Vikram Bhatt]]","[[Reliance Entertainment]]"],
			    "companies":["[[Reliance Big Pictures]]","[[ASA Productions and Enterprises Pvt. Ltd.]]","[[Reliance Entertainment]]"],
			    "year":2008}))

		test_helper("This Rebel Breed",
			%Q({"title":"This Rebel Breed",
			    "cast":["[[Rita Moreno]]","[[Mark Damon]]","[[Gerald Mohr]]","[[Jay Novello]]","[[Eugene Martin (actor)|Eugene Martin]]","[[Tom Gilson]]","[[Richard Rust]]","[[Douglas Hume]]","[[Richard Laurier]]","[[Don Eitner]]","[[Dyan Cannon]]","Ken Miller","[[Al Freeman Jr.]]","[[Charles Franc]]","[[Ike Jones]]","[[Shirley Falls]]","[[Steven Perry (actor)|Steven Perry]]","[[Hari Rhodes]]"],
			    "directors":["[[Richard L. Bare]]","[[William Rowland]]"],
			    "producers":["[[William Rowland]]","[[Robert Yamin]]"],
			    "companies":["All God's Children Co.","[[Warner Bros.]]"],
			    "year":1960}))

		# cast has *chapter-headings with actors listed as **subheadings
		skip_test_helper("The Ballad of Buster Scruggs",
			%Q({"title":"The Ballad of Buster Scruggs",
			    "cast":["[[Tyne Daly]]","[[James Franco]]","[[Brendan Gleeson]]","[[Zoe Kazan]]","[[Liam Neeson]]","[[Tim Blake Nelson]]","[[Tom Waits]]","[[Willie Watson (musician)|Willie Watson]]","[[David Krumholtz]]","E.E. Bell","[[Tom Proctor (actor)|Tom Proctor]]","[[Clancy Brown]]","[[Stephen Root]]","[[Ralph Ineson]]","[[Jesse Luken]]","[[Harry Melling (actor)|Harry Melling]]","Sam Dillon","[[Zoe Kazan]]","[[Bill Heck]]","[[Grainger Hines]]","Jackamoe Buzzell","[[Jefferson Mays]]","Ethan Dubin","[[Jonjo O'Neill (actor)|Jonjo O'Neill]]","[[Saul Rubinek]]","[[Chelcie Ross]]"],
			    "directors":["[[Coen brothers|Joel Coen","Ethan Coen]]"],
			    "producers":["Joel Coen","Ethan Coen","[[Megan Ellison]]","[[Sue Naegle]]","Robert Graf"],
			    "companies":["[[Annapurna Pictures]]","[[Coen Brothers|Mike Zoss Productions]]","[[Netflix]]"],
			    "year":2018}))

		# cast has *chapter-headings with actors listed as **subheadings
		skip_test_helper("Malibu Express",
			%Q({"title":"Malibu Express",
			    "cast":["[[Darby Hinton]]","[[Sybil Danning]]","[[Lynda Wiesmeier]]","Lori Sutton","[[Art Metrano]]","Shelley Taylor Morgan","Brett Baxter Clark","Niki Dantine","Lorraine Michaels","Kimberly McArthur","Barbara Edwards","Abb Dickson","Busty O'Shea","Randy Rudy","Michael A. Andrews","Richard Brose","John Brown","Suzanne M. Regard","John Alderman","Robyn Hilton","Les Steinmetz","Robert Darnell","Jeanine Vargas","Peter Knecht","Harry Hauss","Ruth Stamer","Peggy Ann Filsinger","[[Regis Philbin]]","Joy Philbin","Niki Patterson"],
			    "directors":["[[Andy Sidaris]]"],
			    "producers":["[[Andy Sidaris]]"],
			    "companies":["Malibu Bay Films","[[Universal Studios]]"],
			    "year":1985}))

		skip_test_helper("The Ballad of Buster Scruggs",
			%Q({"title":"The Ballad of Buster Scruggs",
			    "cast":["[[Tyne Daly]]","[[James Franco]]","[[Brendan Gleeson]]","[[Zoe Kazan]]","[[Liam Neeson]]","[[Tim Blake Nelson]]","[[Tom Waits]]","[[Willie Watson (musician)|Willie Watson]]","[[David Krumholtz]]","E.E. Bell","[[Tom Proctor (actor)|Tom Proctor]]","[[Clancy Brown]]","[[Stephen Root]]","[[Ralph Ineson]]","[[Jesse Luken]]","[[Harry Melling (actor)|Harry Melling]]","Sam Dillon","[[Zoe Kazan]]","[[Bill Heck]]","[[Grainger Hines]]","Jackamoe Buzzell","[[Jefferson Mays]]","Ethan Dubin","[[Jonjo O'Neill (actor)|Jonjo O'Neill]]","[[Saul Rubinek]]","[[Chelcie Ross]]"],
			    "directors":["[[Coen brothers|Joel Coen","Ethan Coen]]"],
			    "producers":["Joel Coen","Ethan Coen","[[Megan Ellison]]","[[Sue Naegle]]","Robert Graf"],
			    "companies":["[[Annapurna Pictures]]","[[Coen Brothers|Mike Zoss Productions]]","[[Netflix]]"],
			    "year":2018}))

		# can we parse things like /(Name Name) \b(?:appears|plays|portrays|as|cameos|has a cameo)\b/ ?
		skip_test_helper("Ghostbusters II",
			%Q({"title":"Ghostbusters II","cast":["[[Bill Murray]]","[[Dan Aykroyd]]","[[Sigourney Weaver]]","[[Harold Ramis]]","[[Rick Moranis]]","[[Ernie Hudson]]","[[Annie Potts]]","[[Peter MacNicol]]","[[Kurt Fuller]]","[[David Margulies]]","[[Harris Yulin]]","[[Janet Margolin]]","William T. Deutschendorf","[[Wilhelm von Homburg]]","[[Brian Doyle-Murray]]","Karen Humber","[[Mary Ellen Trainor]]","[[Cheech Marin]]","[[Philip Baker Hall]]","[[Ben Stein]]","[[Louise Troy]]"],"directors":["[[Ivan Reitman]]"],"producers":["[[Ivan Reitman]]"],"companies":["[[Columbia Pictures]]"],"year":1989}))

		# These two (and many others) raised exceptions in
		# split_around_markup, because the caller expand_brace_commands was
		# generating blocks with mismatched sets of {{braces}}.
		test_helper("Enter the Dragon",
			%Q({"title":"Enter the Dragon","cast":["[[Bruce Lee]]","[[John Saxon]]","[[Ahna Capri]]","[[Robert Wall|Bob Wall]]","[[Shih Kien]]","[[Jim Kelly (martial artist)|Jim Kelly]]","[[Robert Wall]]","[[Angela Mao]]","[[Betty Chung]]","[[Geoffrey Weeks]]","[[Bolo Yeung]]","[[Peter Archer (actor)|Peter Archer]]","Ho Lee Yan","[[Marlene Clark]]","Allan Kent","William Keller","Mickey Caruso","[[Pat E. Johnson]]","[[Darnell Garcia]]","Mike Bissell","[[Jackie Chan]]","[[Sammo Hung]]","[[Roy Chiao]]","[[Paul Heller]]","[[Lam Ching Ying]]","[[Tony Liu]]","[[Alan Chui Chung-San]]","[[Yuen Biao]]","[[Antone Pagan]]","[[Yuen Wah]]","[[Hidy Ochiai]]","Wei Tung","[[Tadashi Yamashita]]","[[Mars (actor)|Mars]]","Mang Hoi"],"directors":["[[Robert Clouse]]"],"producers":["[[Fred Weintraub]]","[[Paul Heller]]","[[Raymond Chow]]"],"companies":["[[Warner Bros.]]","[[Concord Production Inc.]]","[[Orange Sky Golden Harvest|Golden Harvest]]"],"year":1973}))
		test_helper("The Empire Strikes Back",
			%Q({"title":"The Empire Strikes Back","cast":["[[Mark Hamill]]","[[Harrison Ford]]","[[Carrie Fisher]]","[[Billy Dee Williams]]","[[Anthony Daniels]]","[[David Prowse]]","[[Kenny Baker (English actor)|Kenny Baker]]","[[Peter Mayhew]]","[[Frank Oz]]"],"directors":["[[Irvin Kershner]]"],"producers":["[[Gary Kurtz]]"],"companies":["[[Lucasfilm Ltd.]]","[[20th Century Fox]]"],"year":1980}))

		# These two think "Director" is a person's name.  It's a common enough
		# problem that "Director" shows up in the top-1000 best centers list.
		test_helper("Run for Love",
			%Q({"title":"Run for Love","cast":["[[Zhang Ziyi]]","[[Eddie Peng]]","[[Tong Liya]]","[[Zhou Dongyu]]","[[Michelle Chen]]","[[Zhang Yi (actor)|Zhang Yi]]","[[Liang Jing]]","[[Wang Qianyuan]]","[[Wu Mochou]]","Sebastian Stigar","[[Per Christian Ellefsen]]","Janny Hoff Brekke","Sigmund Sæverud","Trond Halbo","Geir Tangen","[[Brian Rooney (American actor)|Brian Rooney]]"],"directors":["[[Zhang Yibai]]","[[Guan Hu]]","[[Zhang Meng (director)|Zhang Meng]]","[[Teng Huatao]]","[[Gao Qunshu]]"],"producers":["Xu Wen"],"companies":["Beijing Wynn Culture & Media","Shannan Guangxian Pictures","Chuandi Guangnian Entertainment","[[Huayi Brothers]]","Shenzhen Huiye Goldstone Management Company","Wuhan Xinghao Film & Culture","Beijing Monster Pictures","Chengdu Zhiyou Culture Communication Company","Wang Yuelun Studio","Beijing Yixiang Tiankai Media"],"year":2016}))
		test_helper("The Cannonball Run",
			%Q({"title":"The Cannonball Run","cast":["[[Burt Reynolds]]","[[Roger Moore]]","[[Farrah Fawcett]]","[[Dom DeLuise]]","[[Dean Martin]]","[[Sammy Davis Jr.]]","[[Adrienne Barbeau]]","[[Jamie Farr]]","[[Terry Bradshaw]]","[[Mel Tillis]]","[[Jackie Chan]]","[[Michael Hui]]","[[George Furth]]","[[Peter Fonda]]","[[Bert Convy]]","[[Jack Elam]]","[[Rick Aviles]]","[[John Fiedler]]","[[Joe Klecko]]","[[Hal Needham]]","[[Ken Squier]]","[[June Foray]]"],"directors":["[[Hal Needham]]"],"producers":["[[Albert S. Ruddy]]"],"companies":["[[Orange Sky Golden Harvest|Golden Harvest]]","[[20th Century Fox]]","[[Warner Bros. Pictures]]","[[HBO Films]]","[[Media Asia|Media Asia Distribution]]","[[Star China Media|Fortune Star Media Ltd.]]"],"year":1981}))

		# A better test for The Cannonball Run
		# This line should produce two actors:
		#   - [[Adrienne Barbeau]] and [[Tara Buckman]] as Marcie Thatcher and Jill Rivers
		skip_test_helper("The Cannonball Run",
			%Q({"title":"The Cannonball Run","cast":["[[Burt Reynolds]]","[[Roger Moore]]","[[Farrah Fawcett]]","[[Dom DeLuise]]","[[Dean Martin]]","[[Sammy Davis Jr.]]","[[Adrienne Barbeau]]","[[Jamie Farr]]","[[Terry Bradshaw]]","[[Mel Tillis]]","[[Jackie Chan]]","[[Michael Hui]]","[[George Furth]]","[[Tara Buckman]]","[[Peter Fonda]]","[[Bert Convy]]","[[Jack Elam]]","[[Rick Aviles]]","[[John Fiedler]]","[[Joe Klecko]]","[[Hal Needham]]","[[Ken Squier]]","[[June Foray]]"],"directors":["[[Hal Needham]]"],"producers":["[[Albert S. Ruddy]]"],"companies":["[[Orange Sky Golden Harvest|Golden Harvest]]","[[20th Century Fox]]","[[Warner Bros. Pictures]]","[[HBO Films]]","[[Media Asia|Media Asia Distribution]]","[[Star China Media|Fortune Star Media Ltd.]]"],"year":1981}))
	end

	def test_tv_shows
		# These are TV shows, so they don't get parsed as movies.
		test_helper_empty("Hercules: The Legendary Journeys")
		test_helper_empty("Matlock (TV series)")
		test_helper_empty("The Dukes of Hazzard")
		test_helper_empty("Twin Peaks")
	end

	def test_people
		# These are people, so they don't get parsed as movies.
		test_helper_empty("Werner Herzog")
	end

	def test_redirect
		test_helper_empty("redirect")
	end

private
	def test_helper(fn, expect_json, ignore_mismatch=false)
		count = 0
		File.open("fixtures/#{fn}.xml") do |fp|
			parser = Parser.new do |movie|
				count += 1
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
		assert_equal 1, count
	end

	def skip_test_helper(fn, expect_json)
		test_helper(fn, expect_json, true)
	end

	def test_helper_empty(fn)
		File.open("fixtures/#{fn}.xml") do |fp|
			parser = Parser.new do |movie|
				fail "Got an unexpected movie from \"#{fn}\""
			end
			Ox.sax_parse(parser, fp, :skip => :skip_none)
		end
	end
end
