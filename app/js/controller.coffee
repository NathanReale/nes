class window.Controller
	constructor: ->
		@lastInput = 0
		@index = 0
		@state = [0, 0, 0, 0, 0, 0, 0, 0]

		that = this
		window.onkeydown = (key)->
			that.setKey(key, 1)
		window.onkeyup = (key)->
			that.setKey(key, 0)
	
	write: (value) ->
		if @lastInput == 1 and value == 0
			@index = 0
		@lastInput = value

	read: ->
		ret = 0
		if @index < 8
			ret = @state[@index]

		@index = (@index + 1) % 24

		#console.log "read", @index, ret
		return ret


	setKey: (key, value) ->
		switch key.keyCode
			when 65
				@state[0] = value
			when 66
				@state[1] = value
			when 90
				@state[2] = value
			when 88
				@state[3] = value
			when 38
				@state[4] = value
			when 40
				@state[5] = value
			when 37
				@state[6] = value
			when 39
				@state[7] = value