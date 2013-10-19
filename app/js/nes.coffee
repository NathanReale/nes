window.NES = ->
	nes =
		reg:
			pc: new Register(16)
			s: new Register(8)
			x: new Register(8)
			y: new Register(8)
			a: new Register(8)
