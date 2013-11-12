class window.Register
	constructor: (@bits) ->
		@val = 0
		@zero = true
		@carry = @overflow = @neg = false
		@max = Math.pow(2, @bits)

	add: (value, carry = false) ->
		if Math.abs(value) >= @max
			throw "Invalid value: " + value

		prev = @val

		@val += value

		# Add carry if requested
		if carry
			@val += 1
		
		# Update flags and set val to be between 0 and max
		@overflow = (prev < @max/2 and value < @max/2 and @val >= @max/2) or
			(prev >= @max/2 and value >= @max/2 and @val < @max/2)

		@carry = (@val >= @max)
		@val = (@val+@max) % @max

		@zero = (@val == 0)
		@neg = (@val >= @max/2)

	sub: (value, carry = false) ->
		if Math.abs(value) >= @max
			throw "Invalid value: " + value

		prev = @val

		@val -= value

		# Add carry if requested
		if carry
			@val -= 1
		
		# Update flags and set val to be between 0 and max
		@overflow = (prev < @max/2 and value >= @max/2 and @val >= @max/2) or
			(prev >= @max/2 and value < @max/2 and @val < @max/2)

		@carry = (@val >= @max)
		@val = (@val+@max) % @max

		@zero = (@val == 0)
		@neg = (@val >= @max/2)

	shiftRight: (carry = false) ->
		@carry = (@val & 0x1) != 0
		
		@val = @val >> 1

		@val |= 0x80 if carry

		@zero = (@val == 0)
		@neg = (@val >= @max/2)

	shiftLeft: (carry = false) ->
		@carry = (@val & 0x80) != 0
		
		@val = (@val << 1) & 0xFF

		@val |= 0x01 if carry

		@zero = (@val == 0)
		@neg = (@val >= @max/2)

	set: (value) ->
		if Math.abs(value) >= @max
			throw "Invalid value: " + value

		@val = (value+@max) % @max

		@zero = (@val == 0)
		@neg = (@val >= @max/2)