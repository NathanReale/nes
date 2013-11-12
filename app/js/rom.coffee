class window.ROM

	# Expects to be passed a Uint8Array of data
	constructor: (@data) ->
		if @data[0] != 0x4e or @data[1] != 0x45 or @data[2] != 0x53 or @data[3] != 0x1A
			throw "Invalid file"

		@prgSize = data[4]
		@chrSize = data[5]
		@flag6 = data[6]
		@flag7 = data[7]
		@ramSIze = data[8]
		@flag9 = data[9]
		@flag10 = data[10]

		# The mapper id is stored in the upper 4 bits of two different flags
		@mapper = (@flag7 & 0xF0) | (@flag6 >> 4)

		@prg = @data.subarray(0x10, (0x4000 * @prgSize) + 0x10)
		@chr = @data.subarray((0x4000 * @prgSize) + 0x10, (0x4000 * @prgSize) + 0x10 + (0x2000 * @chrSize))



	get: (addr) ->
		if addr >= 0x8000 and addr < 0x10000
			return @prg[addr%(0x4000 * @prgSize)]

	getVRom: (addr) ->
		if addr >= 0x0 and addr < 0x2000
			return @chr[addr]