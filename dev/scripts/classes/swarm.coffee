config  = require 'config'
ui      = require 'classes/ui'
canvas  = require 'classes/canvas'
sounds  = require 'classes/sounds'
Invader = require 'classes/invader'

class Swarm

	shootRows: []
	ufoRandomizer: 0
	speedStep: config.invaders.speedStep
	step:
		x: config.invaders.step[0]
		y: config.invaders.step[1]
	offset:
		x: (canvas.width / 2) - ((config.invaders.cell[0] * config.invaders.columns) / 2)
		y: canvas.height / 3.6
	cell:
		x: config.invaders.cell[0]
		y: config.invaders.cell[1]
	size:
		x: config.invaders.columns
		y: config.invaders.rows.length

	# Swarm constructor
	constructor: (p) ->

		_.extend @, p

		@ufo = new Invader
			alive: false
			type: 'ufo'
			checkHitForBullet: @checkHitForBullet
			getBulletType: ->
				'ufo'

		@ufo.coords =
			x: canvas.width
			y: 55

		@init()

	# Init
	init: ->

		@rows = []
		@dir = 1
		@charging = false
		@lastRow = 5
		@counter = config.invaders.maxsteps / 2
		@speed = config.invaders.speed

		@ufo.alive = false
		@ufoRandomizer = 0

		_.each config.invaders.rows, (type, rowI, rows) =>

			@rows[rowI] =
				x: 0
				y: 0
				type: type
				invaders: []

			_.times @size.x, (n) =>
				@rows[rowI].invaders[n] = new Invader
					type: type
					checkHitForBullet: @checkHitForBullet

		@canShoot()

	# Check Bullet Hit
	checkHit: (x, y, w, h) ->
		(
			(
				if invader.checkHit x, y, w, h
					@canShoot()
					return true
			) for invader in row.invaders
		) for row in @rows
		false

	# Cache Invaders Able To Shoot
	canShoot: ->
		cache = []
		@lastRow = 0
		(
			columnCanShoot = false
			(
				if @rows[rowI].invaders[columnI].alive
					columnCanShoot = rowI
					if rowI > @lastRow
						@lastRow = rowI
			) for rowI in [0..@size.y-1]
			if columnCanShoot isnt false
				cache.push [ columnI, columnCanShoot ]
		) for columnI in [0..@size.x-1]
		@shootRows = cache

	# Random Invader Shoot
	shoot: ->
		if ui.state isnt 'game' or ui.isPaused() or @shootRows.length is 0
			return
		i = _.random 0, @shootRows.length-1
		@rows[@shootRows[i][1]].invaders[@shootRows[i][0]].shoot()

	# Move swarm
	move: ->

		if ui.isPaused()
			return

		if !@ufo.alive
			@ufoRandomizer += 1
			if _.random(0, 90 + @ufoRandomizer) > 100
				@ufoRandomizer = 0
				@startUfoMoving()

		if @counter >= config.invaders.maxsteps
			@counter = 0
			@dir *= -1
			@faster()
			_vertical = true
			if @rows[@lastRow].y + (@cell.y * @lastRow - 1) + @step.y + @offset.y > (canvas.height - 26)
				ui.end()

		else
			_horisontal = true
			@counter++

		_.each @rows, (row, rowI, rows) =>
			setTimeout ( =>
				# Individual animation
				_.each row.invaders, (invader, invaderI, invaders) =>
					invader.nextFrame()
				# Step by step moving
				if _vertical
					row.y += @step.y
				else if _horisontal
					row.x += @step.x * @dir
			), ((@speed / @size.y) * (@size.y - rowI))

	# Start ufo moving
	startUfoMoving: ->
		@ufo.alive = true
		@ufo.coords.x = canvas.width
		@ufo.shootOn = _.random 8, canvas.width - 8
		sounds.ufo.play()
		sounds.ufoPlaying = true

	# Ufo moving
	ufoMove: ->

		unless ui.isPaused()
			@ufo.coords.x -= 2

		@ufo.draw @ufo.coords.x, @ufo.coords.y

		if @ufo.coords.x > @ufo.shootOn - 2 and @ufo.coords.x < @ufo.shootOn + 2 and !ui.isPaused()
			@ufo.shoot()

		if @ufo.coords.x < (0 - @ufo.width)
			@ufo.alive = false


	# Start moving
	startMoving: ->
		@movingInterval = setInterval ( =>
			@move()
		), (@speed + (@speed / @size.y))

	# Stop moving
	stopMoving: ->
		clearInterval @movingInterval

	# Make moving faster
	faster: ->
		@stopMoving()
		@speed -= @speedStep
		if @speed < 25
			@speed = 25
		@startMoving()

	# Draw the swarm
	draw: ->
		_.each @rows, (row, rowI, rows) =>
			_.each row.invaders, (invader, invaderI, invaders) =>
				invader.draw row.x + @offset.x + (invaderI * @cell.x), row.y + @offset.y + (rowI * @cell.y)

		if !@charging and !ui.isPaused()
			@charging = true
			setTimeout ( =>
				@shoot()
				@charging = false
			), @speed * 2 + 250

		if @ufo.alive
			@ufoMove()

		unless @ufo.alive and sounds.ufoPlaying
			sounds.stop 'ufo'
			sounds.ufoPlaying = false

module.exports = Swarm
