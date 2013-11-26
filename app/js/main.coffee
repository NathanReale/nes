currentInterval = null
cache = []

window.start = ->

	for x in [0...240]
		cache[x] = []
		for y in [0...256]
			cache[x][y] = 0

	romList = [
		{file:'nestest.nes', name:'NES Test'}
		{file:'nestress.nes', name:'NEStress'}
		{file:'nes15.nes', name:'NES 15'}
		{file:'Donkey Kong.nes', name:'Donkey Kong'}
		{file:'Donkey Kong Jr.nes', name:'Donkey Kong Jr.'}
		{file:'SuperMarioBros.nes', name:'Super Mario Bros.'}
	]
	selectedRom = 'Donkey Kong Jr.'

	romSel = document.getElementById('roms')
	stopButton = document.getElementById('stop')

	# Build the drop down list of roms
	for rom in romList
		option = document.createElement('option')
		option.text = rom.name
		option.value = rom.file
		if rom.name == selectedRom
			option.selected = 'selected'
		romSel.appendChild(option)

	# Stop the currently running rom, if there is one
	stopButton.onclick = (e) ->
		if currentInterval != null
			clearInterval(currentInterval)

	# When the user selects a different rom, stop anything currently running and load the new rom
	romSel.onchange = (e) ->
		if currentInterval != null
			clearInterval(currentInterval)
		runRom(e.target.value, 'screen', 1000, 3, false)

	# Start the initial rom
	runRom(romSel.value, 'screen', 1000, 3, false)


window.testRoms = () ->
	runRom 'palette_ram.nes', 'palette_ram', 200
	runRom 'vram_access.nes', 'vram_access', 200
	runRom 'sprite_ram.nes', 'sprite_ram', 200


drawRow = (row, x, ctx, scale = 1) ->
	for y in [0...256]
		if row[y] != cache[x][y]
			ctx.fillStyle = row[y]
			ctx.fillRect(y*scale, x*scale, scale, scale)
			cache[x][y] = row[y]

# Debugging - prints the entire screen as once
printScreen = (nes, canvas, scale = 1) ->
	ctx = canvas.getContext('2d');

	for x in [0...240] by 1
		row = nes.ppu.debugScanLine(x)
		drawRow(row, x, ctx, scale)

runRom = (name, canvasName, frames, scale = 1, debug = false) ->
	run = (data) ->
		nes = new NES(data, debug)

		canvas = document.getElementById(canvasName)
		canvas.width = (256*scale)
		canvas.height = (240*scale)
		ctx = canvas.getContext('2d');
		
		counter = 0
		cyclesLeft = 0
		currentInterval = setInterval( ->
			console.log("Frame", counter)

			if counter == frames
				clearInterval(currentInterval)
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

	# Check if the rom is already stored locally
	if localStorage[name]
		run str2ab(localStorage[name])
	else # Load it from the server
		xhr = new XMLHttpRequest
		xhr.onload = ->
			rom = new Uint8Array(this.response)
			localStorage[name] = ab2str(this.response)
			run rom
				
		xhr.open 'GET', 'img/' + name, true
		xhr.responseType = 'arraybuffer'
		xhr.send()
