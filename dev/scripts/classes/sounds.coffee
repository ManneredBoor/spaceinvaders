config = require 'config'

class Sounds

	muted: false
	ufoPlaying: true

	toggle: ->
		unless Modernizr.touch
			if @muted
				@unmute()
			else
				@mute()

	mute: ->
		unless Modernizr.touch
			@muted = true
			@ufo.volume 0
			@cannonShoot.volume 0
			@cannonBang.volume 0
			@invaderBang.volume 0
			@invadershoot.volume 0

	unmute: ->
		unless Modernizr.touch
			@muted = false
			@ufo.volume 0.175
			@cannonShoot.volume 0.25
			@cannonBang.volume 0.25
			@invaderBang.volume 0.25
			@invadershoot.volume 0.175

	stop: (sound) ->
		unless Modernizr.touch
			@[sound].stop()

	play: (sound) ->
		unless Modernizr.touch
			@[sound].play()

	constructor: ->

		unless Modernizr.touch
			@ufo = new Howl
				urls: [ 'sounds/ufo.wav' ]
				loop: true
				volume: 0.175

			@cannonShoot = new Howl
				urls: [ 'sounds/shoot.wav' ]
				volume: 0.25

			@cannonBang = new Howl
				urls: [ 'sounds/explosion.wav' ]
				volume: 0.25

			@invaderBang = new Howl
				urls: [ 'sounds/invaderkilled.wav' ]
				volume: 0.25

			@invadershoot = new Howl
				urls: [ 'sounds/invadershoot.wav' ]
				volume: 0.175


sounds = new Sounds
module.exports = sounds
