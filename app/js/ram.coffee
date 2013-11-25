class window.Ram
	constructor: (@rom, @controller) ->
		@ram = (0xFF for num in [0...0x800])
		@apu = (0x00 for num in [0...0x20])

		@ppu = null

	setPPU: (@ppu) ->

	get: (index) ->
		if index >= 0 and index < 0x2000
			return @ram[index%0x800]

		if index >= 0x2000 and index < 0x4000
			return @ppu.getReg(index%8)

		if index == 0x4016
			return @controller.read()

		if index >= 0x4000 and index < 0x4020
			return @apu[index%0x20]

		if index >= 0x8000 and index < 0x10000
			return @rom.get(index)

		throw "Invalid index " + index

	set: (index, value) ->
		if value > 0xFF or value < 0
			throw "Invalid value " + value

		if index >= 0 and index < 0x2000
			@ram[index%0x800] = value
		else if index >= 0x2000 and index < 0x4000
			@ppu.setReg(index%8,  value)
		else if index == 0x4014
			@ppu.oamDma(value)
		else if index == 0x4016
			@controller.write(value)
		else if index >= 0x4000 and index < 0x4020
			@apu[index%0x20] = value
		else
			throw "Invalid index 0x" + index.toString(16)

