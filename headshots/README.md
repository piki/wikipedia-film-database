# Headshots scraper for wikipedia-film-database

This directory contains two experimental scripts, to download and crop actor headshots from Wikipedia.

## get-image

Run `./get-image "Actor Name"` to download images of an actor.

Specifically, it will:
  1. Extract the article from the current Wikipedia download and call it "Actor Name.xml"
  2. Parse out image links from the article
  3. Download the metadata, including license, for those images, and store the license as "images/Actor Name/Image File.license"
  4. Download the image file itself and store it as "images/Actor Name/Image File"

## cropper.js

`cropper.js` is a web page to crop circular headshots out of the images that `get-image` downloads.

Edit `cropper.js` and fill in the `IMAGES` array with the filenames you want to crop.  Then open `cropper.html` in a web browser.  Page through the images with the left/right or up/down arrows.  Jump to a specific image number by typing the number and hitting enter.  Crop an image by dragging a circle from the center to an edge.  As you crop, a list will form at the bottom in CSV form with image names and the width, height, left offset, top offset, original width, and original height of each crop.

Copy and paste the contents of the CSV to a file called `crops.csv`.  When you are done, if you have ImageMagick (i.e., `convert`) installed, you can run `./apply-crops` to automate the process of cropping all images mentioned in `crops.csv`.  For each `Image File` mentioned in `crops.csv`, the `apply-crops` script will create `images/Actor Name/crop-Image File` that is a square crop circumscribed around the circle you chose.
