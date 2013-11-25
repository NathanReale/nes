window.start = ->
	#romName = 'nestest.nes'
	#romName = 'nestress.nes'
	#romName = 'nes15.nes'

	#romName = 'Donkey Kong.nes'
	romName = 'Donkey Kong Jr.nes'
	#romName = 'SuperMarioBros.nes'

	if localStorage[romName]
		run str2ab(localStorage[romName])
	else 
		xhr = new XMLHttpRequest
		xhr.onload = ->
			rom = new Uint8Array(this.response)
			localStorage[romName] = ab2str(this.response)
			run rom
				
		xhr.open 'GET', 'img/' + romName, true
		xhr.responseType = 'arraybuffer'
		xhr.send()

window.run = (data) ->
	nes = new NES(data, false)
	#nes.reg.p.set(0xC000)

	#while nes.step() then
	#nes.step() for c in [0...24758]
	# nes.step() for num in [0...25000]
	# nes.cpu.triggerNMI()
	# nes.step() for num in [0...25000]
	# nes.debug()

	canvas = document.getElementById('screen')
	scale = 3
	canvas.width = (256*scale)
	canvas.height = (240*scale)
	ctx = canvas.getContext('2d');
	
	#nes.step() for num in [0...25000]

	counter = 0
	cyclesLeft = 0
	interval = setInterval( ->
		console.log("Frame", counter)

		if counter == 500
			clearInterval(interval)
			#printScreen(nes, canvas, 3)
			#nes.ppu.debug()
		counter += 1

		scanline = 0
		ppuX = 0
		while scanline < 261
			if cyclesLeft == 0
				cyclesLeft = nes.step()

			ppuX += 3
			cyclesLeft -= 1

			if ppuX >= 340
				if scanline == 0
					nes.ppu.endVblank()

				if scanline > 0 and scanline <= 240
					row = nes.ppu.debugScanLine(scanline-1)
					drawRow(row, scanline-1, ctx, scale)

				if scanline == 241
					if (nes.ppu.reg[0] & 0x80) != 0
						nes.cpu.triggerNMI()
					nes.ppu.startVblank()

				scanline += 1
				ppuX -= 340

	, 1000.0/60)

window.testRoms = () ->
	runRom 'palette_ram.nes', 'palette_ram', 20
	runRom 'vram_access.nes', 'vram_access', 20
	runRom 'sprite_ram.nes', 'sprite_ram', 20

cache = []
for x in [0...240]
	cache[x] = []
	for y in [0...256]
		cache[x][y] = 0

drawRow = (row, x, ctx, scale = 1) ->
	for y in [0...256]
		if row[y] != cache[x][y]
			ctx.fillStyle = row[y]
			ctx.fillRect(y*scale, x*scale, scale, scale)
			cache[x][y] = row[y]


printScreen = (nes, canvas, scale = 1) ->
	ctx = canvas.getContext('2d');

	for x in [0...240] by 1
		row = nes.ppu.debugScanLine(x)
		drawRow(row, x, ctx, scale)

	# for row in [0...30] by 1
	# 	for col in [0...32] by 1
	# 		tile = nes.ppu.debugNameTable(row, col)

	# 		for x in [0...8] by 1
	# 			for y in [0...8] by 1
	# 				ctx.fillStyle = tile[x][y]
	# 				ctx.fillRect(col*(8*scale) + (y*scale), row*(8*scale) + (x*scale), scale, scale)


	# for s in [0...64]
	# 	sprite = nes.ppu.debugSprite(s)
	# 	for x in [0...8] by 1
	# 		for y in [0...8] by 1
	# 			ctx.fillStyle = sprite.tile[x][y]
	# 			ctx.fillRect((sprite.x * scale) + (y*scale), (sprite.y * scale) + (x*scale), scale, scale)

runRom = (name, canvasName, frames) ->
	run = (data) ->
		nes = new NES(data, false)

		canvas = document.getElementById(canvasName)
		ctx = canvas.getContext('2d');
		
		counter = 0
		cyclesLeft = 0
		interval = setInterval( ->

			if counter == frames
				clearInterval(interval)
				#printScreen(nes, canvas, 3)
			counter += 1

			scanline = 0
			ppuX = 0
			while scanline < 261
				if cyclesLeft == 0
					cyclesLeft = nes.step() * 8

				ppuX += 1
				cyclesLeft -= 1

				if ppuX == 256
					if scanline == 0
						nes.ppu.endVblank()

					if scanline > 0 and scanline <= 240
						row = nes.ppu.debugScanLine(scanline-1)
						drawRow(row, scanline-1, ctx, 1)

					if scanline == 241
						if (nes.ppu.reg[0] & 0x80) != 0
							nes.cpu.triggerNMI()
						nes.ppu.startVblank()

					scanline += 1
					ppuX = 0


		, 1000.0/60)

	if localStorage[name]
		run str2ab(localStorage[name])
	else 
		xhr = new XMLHttpRequest
		xhr.onload = ->
			rom = new Uint8Array(this.response)
			localStorage[name] = ab2str(this.response)
			run rom
				
		xhr.open 'GET', 'img/' + name, true
		xhr.responseType = 'arraybuffer'
		xhr.send()
