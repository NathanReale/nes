describe "NES", ->

	describe "Initialization", ->
		When -> @nes = NES()
		Then -> expect(@nes.reg.pc.val).toEqual(0)
		Then -> expect(@nes.reg.s.val).toEqual(0)
		Then -> expect(@nes.reg.a.val).toEqual(0)
		Then -> expect(@nes.reg.x.val).toEqual(0)
		Then -> expect(@nes.reg.y.val).toEqual(0)