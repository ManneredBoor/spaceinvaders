config = require 'config'

class Canvas

	fps: 1000 / 60
	cache: {}
	frameDrawings: []

	# Constructor
	constructor: ->

		# Find canvas
		@canvas = document.getElementById 'space'

		# Calculeting sizes canvas size
		@width = config.invaders.maxsteps * config.invaders.cell[0]
		@height = (3.6 * config.invaders.rows.length) * config.invaders.cell[1]

		# Set scaled size
		@canvas.width = @scale @width
		@canvas.height = @scale @height

		# Main context
		@ctx = @canvas.getContext '2d'

		# Start Drawing
		window.requestAnimationFrame ( =>
			@drawFrame()
		), @canvas

	# Animation Frame
	drawFrame: ->
		@clear()

		func.func() for func in @frameDrawings

		window.requestAnimationFrame ( =>
			@drawFrame()
		), @canvas

	# Add Something To Frame Drawing
	addFrameDraw: (id, priority, func) ->
		@frameDrawings.push
			id: id
			func: func
			priority: priority
		@frameDrawings = _.sortBy @frameDrawings, 'priority'

	# Remove Drawing Function
	removeFrameDraw: (id) ->
		@frameDrawings = _.without @frameDrawings, _.findWhere @frameDrawings, { id: id }

	# Converting size to configured scale
	scale: (x) ->
		x * config.pixel

	# Drawing pixel
	pixel: (x, y, color, ctx = false) ->
		_ctx = if ctx then ctx else canvas.ctx
		x = @scale x
		y = @scale y
		_ctx.fillStyle = color
		_ctx.fillRect x, y, config.pixel, config.pixel

	# Drawing pixels matrix
	drawMatrix: (p) ->
		unless p.hasOwnProperty 'context'
			p.context = @ctx
		unless p.hasOwnProperty 'offset'
			p.offset =
				x: 0
				y: 0
		_.each p.matrix, (row, rowI, rows) =>
			_.each row, (pixel, pixelI, pixels) =>
				if pixel is 1
					canvas.pixel pixelI + p.offset.x, rowI + p.offset.y, p.color, p.context

	# Drawing image
	drawImage: (img, x, y) ->
		x = @scale x
		y = @scale y
		@ctx.drawImage img, x, y

	# Clear main context
	clear: ->
		@ctx.clearRect 0, 0, @canvas.width, @canvas.height

	# Caching canvas filled by fallback
	setCache: (p) ->

		p.width = @scale p.width
		p.height = @scale p.height

		unless @cache.hasOwnProperty p.id
			@cache[p.id] = {}
			@cache[p.id].version = @cache[p.id].width = @cache[p.id].height = undefined
			@cache[p.id].buffer = document.createElement 'canvas'
			@cache[p.id].ctx = @cache[p.id].buffer.getContext '2d'

		if @cache[p.id].width isnt p.width
			@cache[p.id].buffer.width = @cache[p.id].width = p.width

		if @cache[p.id].height isnt p.height
			@cache[p.id].buffer.height = @cache[p.id].height = p.height

		if @cache[p.id] && @cache[p.id].version isnt p.version
			@cache[p.id].version = p.version
			@cache[p.id].ctx.clearRect 0, 0, @cache[p.id].width, @cache[p.id].height
			p.render @cache[p.id].ctx

		# document.body.appendChild @cache[p.id].buffer

	# Get cache by id
	getCache: (id) ->
		@cache[id].buffer

canvas = new Canvas
module.exports = canvas
