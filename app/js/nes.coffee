class window.NES
	constructor: (data, @printDebug = false) ->
		
		@controller = new Controller()
		@rom = new ROM(data)
		@ram = new Ram(@rom, @controller)
		@reg =
			p: new Register(16)
			s: new Register(8)
			x: new Register(8)
			y: new Register(8)
			a: new Register(8)

		# Initialize Values to Power-Up State
		# http://wiki.nesdev.com/w/index.php/CPU_power_up_state

		# Point to top of the stack
		@reg.s.set(0xFD)

		@reg.p.set((@rom.get(0xFFFD) << 8) | @rom.get(0xFFFC))

		# Initialize RAM
		@ram.set(0x0008, 0xF7)
		@ram.set(0x0009, 0xEF)
		@ram.set(0x000a, 0xDF)
		@ram.set(0x000f, 0xBF)

		@ram.set(0x4017, 0x00)
		@ram.set(0x4015, 0x00)
		@ram.set(index, 0xFF) for index in [0x4000..0x400F]

		@cpu = new CPU(@ram, @reg, printDebug)
		@ppu = new PPU(@rom, @ram, @rom.chrSize == 0, printDebug)

		@ram.setPPU(@ppu)


	step: ->
		return @cpu.step()

	statusRegister: ->
		@cpu.statusRegister()

	debug: ->
		@cpu.debug()
		@ppu.debug()


