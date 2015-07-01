config  = require 'config'
canvas  = require 'classes/canvas'

class Blasts

	blasts: config.blasts
	blink: 0

	constructor: ->

		@cache()

	cache: ->

		_.each @blasts, (blast, blastI, blasts) =>
			blast.type = blastI
			blast.width = blast.frame[0].length
			blast.height = blast.frame.length
			canvas.setCache
				id: 'blast-' + blast.type
				width: blast.width
				height: blast.height
				version: blastI
				render: (_ctx) =>
					canvas.drawMatrix
						matrix: blast.frame
						color: blast.color
						context: _ctx

	draw: (type, x, y) ->
		canvas.drawImage canvas.getCache('blast-' + type), x, y

blasts = new Blasts
module.exports = blasts
