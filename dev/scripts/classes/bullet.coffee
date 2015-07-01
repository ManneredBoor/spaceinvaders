config = require 'config'
ui     = require 'classes/ui'
canvas = require 'classes/canvas'

#
# Types:
#  - cannon
#  - invaderWave
#  - invaderRocket
#  - ufo
#

increment = 0

class Bullet

	currentFrame: 0

	# Bullet Constructor
	constructor: (p) ->
		_.extend @, config.bullets[p.type], p
		@id     = increment++
		@width  = @frames[0][0].length
		@height = @frames[0].length
		@cache()

		canvas.addFrameDraw 'bullet-' + @id, 20, =>
			if ui.state isnt 'game'
				@destroy()
				return
			unless ui.keyPaused
				@coords.y += @speed * @dir
			if @coords.y <= 0 or @coords.y >= (canvas.height + @height) or @checkHitForBullet(@targets, @coords.x - @width / 2, @coords.y, @width, @height)
				@destroy()
			@draw @coords.x, @coords.y

	# Change Frame
	nextFrame: ->
		if ++@currentFrame >= @frames.length
			@currentFrame = 0

	# Destroy Bullet
	destroy: ->
		if @onDestroy
			@onDestroy()
		canvas.removeFrameDraw 'bullet-' + @id

	# Prerender All Frames
	cache: ->
		_.each @frames, (frame, frameI, frames) =>
			canvas.setCache
				id: 'bullet-' + @type + '-' + frameI
				width: @width
				height: @height
				version: frameI
				render: (_ctx) =>
					canvas.drawMatrix
						matrix: frame
						color: @color
						context: _ctx

	# Draw Prerendered Frame
	draw: (x, y) ->
		canvas.drawImage canvas.getCache('bullet-' + @type + '-' + @currentFrame), @coords.x - @width / 2, @coords.y
		unless ui.isPaused()
			@nextFrame()

module.exports = Bullet
