config  = require 'config'
input   = require 'classes/input'
canvas  = require 'classes/canvas'
sounds  = require 'classes/sounds'

class Ui extends EventEmitter

	state:       'menu'
	paused:      false
	active:      true
	score:       0
	health:      config.health
	keyPaused:   false
	mainBlock:   document.getElementById 'main'
	endBlock:    document.getElementById 'end'
	winBlock:    document.getElementById 'win'
	playBtns:    document.querySelectorAll '.play'
	scoreBlocks: document.querySelectorAll '.score'

	constructor: ->

		window.onblur = =>
			@pause true

		(
			playBtn.addEventListener 'click', =>

				@mainBlock.classList.add 'i-hidden'
				@endBlock.classList.add 'i-hidden'
				@winBlock.classList.add 'i-hidden'

				@resume true
				@state = 'game'

				if @state is 'start'
					@trigger 'gameStart'
				else
					@state = 'game'
					@trigger 'gameRestart'
					@score = 0
					@health = config.health

		) for playBtn in @playBtns

		document.addEventListener 'keydown', (e) =>
			if @state is 'game' and (e.keyCode is 19 or e.keyCode is 80)
				if @paused and @keyPaused
					@resume true
				else
					@pause true

		if Modernizr.touch
			document.addEventListener 'click', =>
				if @paused and @keyPaused
					@resume true

	isPaused: ->
		@active and @paused

	draw: ->
		if @health > 0 and canvas.cache.cannon
			(
				canvas.drawImage canvas.getCache('cannon'), (5 * (i + 1)) + (i * (canvas.cache.cannon.width / config.pixel)), 5
			) for i in [0..@health-1]

		canvas.ctx.font = '88px Munro-Regular'
		canvas.ctx.fillStyle = '#fff'
		canvas.ctx.fillText 'SCORE: ' + @score, canvas.scale(5), canvas.scale(26)

		if input.isPressed 77
			sounds.toggle()

		if @keyPaused
			canvas.ctx.font = '56px Munro-Regular'
			if Modernizr.touch
				canvas.ctx.fillText 'tap screen to unpause', (canvas.canvas.width / 2) - canvas.scale(36), canvas.scale(46)
			else
				canvas.ctx.fillText 'press p to unpause', (canvas.canvas.width / 2) - canvas.scale(33), canvas.scale(46)


	pause: (key = false) ->
		@paused = true

		if key
			@keyPaused = true
			sounds.mute()

		@trigger 'pause'

	resume: (key = false) ->
		if !key and @keyPaused
			return

		@paused = false

		if key
			@keyPaused = false
			sounds.unmute()

		@trigger 'resume'

	die: ->
		@health--

	checkHealth: ->
		if @health > 0
			return true
		else
			@end()
			return false

	scoreToBlock: ->
		(
			scoreBlock.textContent = 'final score: ' + @score
		) for scoreBlock in @scoreBlocks

	win: ->
		@state = 'win'
		@scoreToBlock()
		@trigger 'gameEnd'
		@winBlock.classList.remove 'i-hidden'

	end: ->
		@state = 'end'
		@scoreToBlock()
		@trigger 'gameEnd'
		@endBlock.classList.remove 'i-hidden'

ui = new Ui
module.exports = ui
