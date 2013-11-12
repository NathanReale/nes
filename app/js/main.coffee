window.start = ->
	#romName = 'nestest.nes'
	romName = 'NEStress.nes'
	#romName = 'palette_ram.nes'
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
	nes.step() for num in [0...400000]
	#nes.debug()

	canvas = document.getElementById('screen')
	printScreen(nes, canvas)

	# counter = 0
	# interval = setInterval( ->

	# 	if counter == 100
	# 		clearInterval(interval)
	# 	counter += 1

	# 	nes.step() for c in [0...1000]
	# 	printScreen(nes, canvas)
	# 	nes.debug()

	# 	1000.0/24)

printScreen = (nes, canvas) ->
	ctx = canvas.getContext('2d');

	for row in [0...30] by 1
		for col in [0...32] by 1
			tile = nes.ppu.debugNameTable(row, col)

			for x in [0...8] by 1
				for y in [0...8] by 1
					ctx.fillStyle = tile[x][y].toString(16)
					ctx.fillRect(col*24 + (y*3), row*24 + (x*3), 3, 3)