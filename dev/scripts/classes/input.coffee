config = require 'config'

class Input

	down: {}
	tilt: {}
	pressed: {}
	horisontalTiltMod: 1

	constructor: ->

		document.addEventListener 'keydown', (e) =>
			@down[e.keyCode] = true

		document.addEventListener 'keyup', (e) =>
			delete @down[e.keyCode]
			delete @pressed[e.keyCode]

		if window.DeviceOrientationEvent
			window.addEventListener 'deviceorientation', ( =>
				@tilt = [event.beta, event.gamma]
				@setTiltMode()
			), true
		else if window.DeviceMotionEvent
			window.addEventListener 'devicemotion', ( =>
				@tilt = [event.acceleration.x * 2, event.acceleration.y * 2]
				@setTiltMode()
			), true
		else
			window.addEventListener 'MozOrientation', ( =>
				@tilt = [orientation.x * 50, orientation.y * 50]
				@setTiltMode()
			), true

	setTiltMode: ->
		if @tilt[0] > 90 or @tilt[0] < -90
			@horisontalTiltMod = -1
		else
			@horisontalTiltMod = 1

	isDown: (keyCode) ->
		@down[keyCode]

	isPressed: (keyCode) ->
		if @pressed[keyCode]
			return false
		else if @down[keyCode]
			return @pressed[keyCode] = true
		false

input = new Input
module.exports = input
