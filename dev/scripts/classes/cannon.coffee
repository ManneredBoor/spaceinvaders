config  = require 'config'
helpers = require 'helpers'
ui      = require 'classes/ui'
input   = require 'classes/input'
sounds  = require 'classes/sounds'
blasts  = require 'classes/blasts'
canvas  = require 'classes/canvas'
Bullet  = require 'classes/bullet'

class Cannon

	alive: true
	bullet: false

	# Cannon Constructor
	constructor: (p) ->
		_.extend @, config.cannon, p
		@width = @pixels[0].length
		@height = @pixels.length
		@cache()

		@init()

	# Init
	init: ->
		@alive = true
		@coords =
			x: (canvas.width / 2) - (@width / 2)
			y: canvas.height - @height - 3

	# Keyboard And Tilt Control
	controls: ->
		if input.isDown 37
			@moveLeft @speed()

		if input.isDown 39
			@moveRight @speed()

		if input.isPressed 32
			@shoot()

		if input.tilt[1] < -3
			@moveLeft (input.tilt[1] / 6 * -1) * input.horisontalTiltMod

		if input.tilt[1] > 3
			@moveRight (input.tilt[1] / 6) * input.horisontalTiltMod

		if Modernizr.touch
			document.addEventListener 'click', =>
				@shoot()

	# Shoot (only one bullet on screen)
	shoot: ->
		unless @bullet
			sounds.play 'cannonShoot'
			@bullet = new Bullet
				type: 'cannon'
				coords:
					x: @coords.x + (@width / 2)
					y: @coords.y
				checkHitForBullet: @checkHitForBullet
				onDestroy: =>
					@bullet = false

	# Get Move Speed
	speed: ->
		if input.isDown 16 then @moveSpeed[1] else @moveSpeed[0]

	# Check Screen Bounds
	checkPos: (newPos) ->
		if newPos <= 6
			newPos = 6
		if newPos >= canvas.width - @width - 6
			newPos = canvas.width - @width - 6
		return newPos

	# Move Cannon Left
	moveLeft: (speed) ->
		@coords.x = @checkPos @coords.x - speed

	# Move Cannon Right
	moveRight: (speed) ->
		@coords.x = @checkPos @coords.x + speed

	# Check Enemy Bullets Hit
	checkHit: (x, y, w, h) ->
		if helpers.intersect x, y, w, h, @coords.x, @coords.y, @width, @height
			@destroy()
			return true
		else
			return false

	# Destroy Cannon
	destroy: ->
		sounds.play 'cannonBang'
		@alive = false
		ui.die()
		ui.pause()
		canvas.addFrameDraw 'cannon-blast', 30, =>
			blasts.draw 'cannon',  @coords.x, @coords.y

		setTimeout ( =>
			if ui.checkHealth()
				@alive = true
				ui.resume()
			canvas.removeFrameDraw 'cannon-blast'
		), 600

	# Cache Drawing Image
	cache: ->
		canvas.setCache
			id: 'cannon'
			width: @width
			height: @height
			version: 1
			render: (_ctx) =>
				canvas.drawMatrix
					matrix: @pixels
					color: '#00FF52'
					context: _ctx

	# Draw Prerendered Frame
	draw: ->
		canvas.drawImage canvas.getCache('cannon'), @coords.x, @coords.y

module.exports = Cannon
