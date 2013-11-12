describe "NES", ->

	describe "Initialization", ->
		Given -> @nes = new NES(null)

		Then -> @nes.reg.p.val == 0x34
		Then -> @nes.reg.s.val == 0xFD
		Then -> @nes.reg.a.val == 0
		Then -> @nes.reg.x.val == 0
		Then -> @nes.reg.y.val == 0
		Then -> @nes.ram.get(0x0000) == 0xFF
		Then -> @nes.ram.get(0x0008) == 0xF7
		Then -> @nes.ram.get(0x0009) == 0xEF
		Then -> @nes.ram.get(0x000a) == 0xDF
		Then -> @nes.ram.get(0x000f) == 0xBF