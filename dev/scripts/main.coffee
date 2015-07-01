Space = require 'classes/space'

window.onload = ->

	FastClick.notNeeded = ->
		false

	FastClick.attach document.body

	space = new Space
