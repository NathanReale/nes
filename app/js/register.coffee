class window.Register
	constructor: (@bits) ->
		@val = 0
		@zero = true
		@carry = @overflow = @neg = false
		@max = Math.pow(2, @bits)

	add: (value) ->
		if value >= @max
			throw "Invalid value: " + value 

		@val += value
		
		# Update flags and set val to be between 0 and max
		@overflow = (Math.abs(@val) > @max/2 || @val == @max/2 )

		@carry = (@val >= @max)
		@val = (@val+@max) % @max

		@zero = (@val == 0)
		@neg = (@val >= @max/2)