config = require 'config'
ui     = require 'classes/ui'
input  = require 'classes/input'
sounds = require 'classes/sounds'
canvas = require 'classes/canvas'
Swarm  = require 'classes/swarm'
Cannon = require 'classes/cannon'

module.exports = class Space

	checkHitForBullet: (targets, x, y, w, h) =>
		(
			if @[target].checkHit(x, y, w, h)
				return true
		) for target in targets
		false

	constructor: ->

		@swarm = new Swarm
			checkHitForBullet: @checkHitForBullet

		@cannon = new Cannon
			checkHitForBullet: @checkHitForBullet

		@ufo = @swarm.ufo

		ui.on 'gameStart', =>
			@swarm.startMoving()

		ui.on 'gameEnd', =>
			@swarm.stopMoving()

			if sounds.ufoPlaying
				sounds.stop 'ufo'
				sounds.ufoPlaying = false

		ui.on 'gameRestart', =>
			@swarm.init()
			@cannon.init()
			@swarm.startMoving()

		canvas.addFrameDraw 'swarm', 20, =>

			if ui.state is 'game'
				ui.draw()
				@swarm.draw()

				if @cannon.alive
					@cannon.draw()

					unless ui.isPaused()
						@cannon.controls()

			if @swarm.shootRows.length is 0
				ui.win()
