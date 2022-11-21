var CROSS_SIZE = 4
var CURRENT_IMAGE = 0
var centerX
var centerY
var radius
var IMG
var SCALE
var RESULTS = []
var jumpTo = ""

function main() {
	CANVAS = document.getElementById("gr")
	CANVAS.addEventListener("mousedown", mouseDown, false)
	CANVAS.addEventListener("mouseup", mouseUp, false)
	CANVAS.addEventListener("mousemove", mouseMove, false)
  window.addEventListener("keydown", keyDown, false)
  window.addEventListener("keypress", keyPressed, false)
	CANVAS.width = 800
	CANVAS.height = 600
	CANVAS.style.width = "800px"
	CANVAS.style.height = "600px"

	setImage(IMAGES[CURRENT_IMAGE])
}

function mouseDown(e) {
	centerX = e.offsetX
	centerY = e.offsetY
	radius = 0
	draw()
}

function mouseUp(e) {
	draw()
	crop = document.getElementById("crop")
	imgLeft = (CANVAS.width - SCALE*IMG.width)/2
	imgTop = (CANVAS.height - SCALE*IMG.height)/2
	cropLeft = Math.round((centerX - radius - imgLeft)/SCALE)
	cropTop = Math.round((centerY - radius - imgTop)/SCALE)
	cropSize = Math.round(2*radius/SCALE)
	crop.innerHTML = `${cropSize}x${cropSize}+${cropLeft}+${cropTop}`
	RESULTS[CURRENT_IMAGE] = `${CURRENT_IMAGE+1},"${IMAGES[CURRENT_IMAGE]}",${cropSize},${cropSize},${cropLeft},${cropTop},${IMG.width},${IMG.height}`
	updateResults()
}

function updateResults() {
	out = document.getElementById("results")
	out.innerHTML = "<pre>" + RESULTS.filter(x => x).join("\n") + "\n</pre>"
}

function mouseMove(e) {
	if ((e.buttons & 1) == 0) { return }
	var dx = e.offsetX - centerX 
	var dy = e.offsetY - centerY 
	radius = Math.sqrt(dx*dx + dy*dy)
	imgLeft = (CANVAS.width - SCALE*IMG.width)/2
	imgTop = (CANVAS.height - SCALE*IMG.height)/2
	radius = Math.min(
		radius,
		imgLeft + IMG.width*SCALE - centerX,
		centerX - imgLeft,
		imgTop + IMG.height*SCALE - centerY,
		centerY - imgTop
	)
	draw()
}

function keyDown(e) {
	if (e.key == "ArrowUp" || e.key == "ArrowLeft") {
		CURRENT_IMAGE = (CURRENT_IMAGE - 1 + IMAGES.length) % IMAGES.length
		setImage(IMAGES[CURRENT_IMAGE])
	}
	if (e.key == "ArrowDown" || e.key == "ArrowRight") {
		CURRENT_IMAGE = (CURRENT_IMAGE + 1) % IMAGES.length
		setImage(IMAGES[CURRENT_IMAGE])
	}
	if (e.key == "Enter" && jumpTo != "") {
		n = parseInt(jumpTo)-1
		console.log(`jumping to ${jumpTo} = ${n}`)
		if (n >= 0 && n < IMAGES.length && n != CURRENT_IMAGE) {
			CURRENT_IMAGE = n
			setImage(IMAGES[CURRENT_IMAGE])
		}
		jumpTo = ""
	}
	if (e.key == "Escape") {
		console.log("cancel")
		jumpTo = ""
	}
	return false
}

function keyPressed(e) {
	console.log(`pressed: ${e.key}`)
	if (e.key >= "0" && e.key <= "9") {
		jumpTo += e.key
		console.log(`jumpTo=${jumpTo}`)
	}
}

function setImage(path) {
	IMG = new Image()
	IMG.onload = function() {
		SCALE = Math.min(1.0*CANVAS.width/IMG.width, 1.0*CANVAS.height/IMG.height)
		draw()
	}
	IMG.src = path
}

function draw() {
  var context = CANVAS.getContext("2d")

  // draw background
  context.fillStyle = "#dddddd"
  context.fillRect(0, 0, CANVAS.width, CANVAS.height)

	imgWidth = IMG.width*SCALE
	imgHeight = IMG.height*SCALE
	imgLeft = (CANVAS.width - SCALE*IMG.width)/2
	imgTop = (CANVAS.height - SCALE*IMG.height)/2
	context.drawImage(IMG, imgLeft, imgTop, imgWidth, imgHeight)

	// draw center, if any
	if (centerX && centerY) {
		context.strokeStyle = "#ff4040"
		context.beginPath()
		context.moveTo(centerX - CROSS_SIZE, centerY)
		context.lineTo(centerX + CROSS_SIZE, centerY)
		context.moveTo(centerX, centerY - CROSS_SIZE)
		context.lineTo(centerX, centerY + CROSS_SIZE)
		context.stroke()

		// draw circle, if any
		if (radius) {
			context.beginPath()
			context.arc(centerX, centerY, radius, 0, 2*Math.PI, false)
			context.stroke()
		}
	}

	counter = document.getElementById("counter")
	counter.innerHTML = `${CURRENT_IMAGE+1}/${IMAGES.length}: ${IMAGES[CURRENT_IMAGE]}<br>${IMG.width}x${IMG.height}`
}

IMAGES = [
	"images/Daniel Radcliffe/Daniel Radcliffe 2009.jpg",
	"images/Daniel Radcliffe/Daniel Radcliffe SDCC 2014.jpg"
]

window.onload = main
