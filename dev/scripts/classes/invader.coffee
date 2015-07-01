config  = require 'config'
helpers = require 'helpers'
ui      = require 'classes/ui'
sounds  = require 'classes/sounds'
blasts  = require 'classes/blasts'
canvas  = require 'classes/canvas'
Bullet  = require 'classes/bullet'

#
# Types:
#  - ufo
#  - squid
#  - crab
#  - jellyfish
#

increment = 0

class Invader

	alive: true
	currentFrame: 0

	# Invader Constructor
	constructor: (p) ->
		_.extend @, p, config.invaders[p.type]
		@id     = increment++
		@width  = @frames[0][0].length
		@height = @frames[0].length
		@coords =
			x: 0
			y: 0
		@cache()

	# Change Frame
	nextFrame: ->
		if ++@currentFrame >= @frames.length
			@currentFrame = 0

	# Prerender All Frames
	cache: ->
		_.each @frames, (frame, frameI, frames) =>
			canvas.setCache
				id: 'invader-' + @type + '-' + frameI
				width: @width + @offset.x
				height: @height + @offset.y
				version: frameI
				render: (_ctx) =>
					canvas.drawMatrix
						matrix: frame
						offset: @offset
						color: @color
						context: _ctx

	# Draw Prerendered Frame
	draw: (x, y) ->
		@coords.x = x
		@coords.y = y
		if @alive
			canvas.drawImage canvas.getCache('invader-' + @type + '-' + @currentFrame), x, y

	# Shoot
	shoot: ->
		sounds.play 'invadershoot'
		bullet = new Bullet
			type: @getBulletType()
			coords:
				x: @coords.x + (@width / 2)
				y: @coords.y
			checkHitForBullet: @checkHitForBullet

	# Get Random Bullet
	getBulletType: ->
		['invaderWave', 'invaderRocket'][_.random 0, 1]

	# Destroy Invader
	destroy: ->
		sounds.play 'invaderBang'
		@alive = false
		ui.score += @score
		canvas.addFrameDraw 'invader-blast-' + @id, 30, =>
			blasts.draw 'invader',  ((@width - 9) / 2) + @coords.x + @offset.x, @coords.y + @offset.y
		setTimeout ( =>
			canvas.removeFrameDraw 'invader-blast-' + @id
		), 160

	# Check Bullet Hit
	checkHit: (x, y, w, h) ->
		if @alive and helpers.intersect x, y, w, h, @coords.x + @offset.x, @coords.y + @offset.y, @width + @offset.x, @height + @offset.y
			@destroy()
			return true
		else
			return false

module.exports = Invader
