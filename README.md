## Overview

This is a little Ruby script to generate a structured movie database from
Wikipedia.

The input is the bzipped XML file containing all [English-language
Wikipedia pages](https://dumps.wikimedia.org/enwiki/).  The output is a
log file containing one JSON blob per line.  Each JSON blob is data from a
single film, with keys for the film's title, cast, director(s),
producer(s), production and distribution companies, and release year.  Any
lines in the output that are not JSON are debugging information (sometimes
indicating a possible error or omission) and can be safely ignored.

The output can be found at https://oracleofbacon.org/data.txt.bz2.

## Licensing

This script copyright 2019 by Patrick Reynolds and may be used and
redistributed according to the terms of the [MIT
license](https://opensource.org/licenses/MIT).

The data this script produces inherits its license from Wikipedia, namely
the [CC BY-SA
3.0](https://en.wikipedia.org/wiki/Wikipedia:Text_of_Creative_Commons_Attribution-ShareAlike_3.0_Unported_License)
license.

## Limitations

Wikipedia is written in prose form, for human readers.  Although there are
some formatting conventions and structured elements, they vary widely from
page to page.  This script parses the majority of film-related pages in
Wikipedia successfully, but it will probably never parse them all.
Typical mistakes include omitting part or all of a film's cast list,
confusing multiple actors with the same name, and sometimes even treating
prose or HTML tags as if they are part of actors' names.  Pull requests
for test cases and/or bug fixes are welcome.

Wikipedia is also a general-interest encyclopedia, not a comprehensive
list of every actor in every film.  In particular, it has about 5% as much
data as the IMDb.  Most popular films and prominent actors and actresses
are covered, but the long tail of old, foreign, and obscure films is not.

This script makes no attempt to parse forms of video entertainment other
than films.  In particular, TV shows and video games are ignored.

## Usage

Download a snapshot from https://dumps.wikimedia.org/enwiki/latest/.  The
file you are looking for will have a name like
`enwiki-20181220-pages-articles-multistream.xml.bz2`.  If you want the
`get-article` script to work, too, download the index file from the same
directory, named something like
`enwiki-20181220-pages-articles-multistream-index.txt.bz2`.

Then decompress the file -- in a pipe, not to a file -- and pipe its
output to `./find-movies`.  For example,

```bash
bzip2 -cd enwiki-20181220-pages-articles-multistream.xml.bz2 | ./find-movies | tee filmdb.txt
```

If you want to extract a single article from Wikipedia, use the
`./get-article` command.  The command searches linearly through the
`index` file, then uses that result to seek directly to the right block in
the `multistream` file.  Articles near the beginning of the index will be
extracted much faster than those at the end.  Articles not present in the
index (not-found errors) will take a long time, so be sure you're
extracting an article that actually exists.

```bash
./get-article "Army of Darkness" > "Army of Darkness.xml"
```

## Development

To run the unit tests, do

```bash
make -C test
```

If you find a movie that doesn't get parsed properly, extract its article
with `./get-article > test/fixtures/name-of-movie.xml`, and add a test
case for it to `test/tc_fixtures.rb`.  Bonus points for fixing the bug,
but even clear test cases are appreciated.
