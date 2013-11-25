class window.PPU
	constructor: (@rom, @ram, @hasChrRam = false, @printDebug = false) ->
		@reg = (0x00 for num in [0...8])
		@vram = (0x00 for num in [0...0x4000])
		@oam = (0x00 for num in [0...0x100])

		@reg[2] = 0x80

		@address = 0
		@oamAddr = 0

		@scrollX = @scrollY = 0

		@readBuffer = 0

		@firstAddr = true
		@firstScroll = true

		@spriteHit = false
		@vblank = false

		@colors = [
			'#7C7C7C', '#0000FC', '#0000BC', '#4428BC', '#940084', '#A80020', '#A81000', '#881400',
			'#503000', '#007800', '#006800', '#005800', '#004058', '#000000', '#000000', '#000000',
			'#BCBCBC', '#0078F8', '#0058F8', '#6844FC', '#D800CC', '#E40058', '#F83800', '#E45C10',
			'#AC7C00', '#00B800', '#00A800', '#00A844', '#008888', '#000000', '#000000', '#000000',
			'#F8F8F8', '#3CBCFC', '#6888FC', '#9878F8', '#F878F8', '#F85898', '#F87858', '#FCA044',
			'#F8B800', '#B8F818', '#58D854', '#58F898', '#00E8D8', '#787878', '#000000', '#000000',
			'#FCFCFC', '#A4E4FC', '#B8B8F8', '#D8B8F8', '#F8B8F8', '#F8A4C0', '#F0D0B0', '#FCE0A8',
			'#F8D878', '#D8F878', '#B8F8B8', '#B8F8D8', '#00FCFC', '#F8D8F8', '#000000', '#000000']

	debug: () ->
		console.log @reg, @hasChrRam, @rom.chr, @vram, @oam

	startVblank: ->
		@vblank = true

	endVblank: ->
		@vblank = false
		@spriteHit = false

	getSpriteHit: ->
		return @spriteHit

	getMirroredAddress: (addr) ->
		#return addr & 0xF7FF
		return addr & 0xFBFF

	getVRam: (addr) ->
		#console.log("get", addr.toString(16))
		if not @hasChrRam and addr < 0x2000
			return @rom.getVRom(addr)
		else if addr >= 0x3000 and addr < 0x3F00
			return @vram[addr - 0x1000]
		else if addr >= 0x3F00 and addr < 0x4000
			addr = addr & 0x1F
			if addr >= 0x10 and (addr & 0x3) == 0
				addr -= 0x10
			return @vram[0x3F00 + addr]
		else if addr >= 0x2000 and addr < 0x3000
			return @vram[@getMirroredAddress(addr)]
		else
			return @vram[addr]

	setVRam: (addr, value) ->
		#console.log("set", addr.toString(16), value.toString(16))
		if addr >= 0x3000 and addr < 0x3F00
			@vram[addr - 0x1000] = value
		else if addr >= 0x3F00 and addr < 0x4000
			addr = addr & 0x1F
			if addr >= 0x10 and (addr & 0x3) == 0
				addr -= 0x10
			@vram[0x3F00 + addr] = value
		else if addr >= 0x2000 and addr < 0x3000
			@vram[@getMirroredAddress(addr)] = value
		else
			@vram[addr] = value

	getReg: (addr) ->
		#console.log "get", addr.toString(16), @address.toString(16)
		switch addr
			when 2
				@firstAddr = @firstScroll = true

				ret = 0
				ret = ret | if @spriteHit then 0x40 else 0x0
				ret = ret | if @vblank then 0x80 else 0x0

				# console.log ret, @spriteHit, @vblank
				return ret
			when 4
				return @oam[@oamAddr]
			when 7
				#console.log(@address.toString(16), @readBuffer, @getVRam(@address))
				if @address >= 0x3F00
					ret = @getVRam(@address)
					@readBuffer = @getVRam(@address - 0x1000)
				else
					ret = @readBuffer
					@readBuffer = @getVRam(@address)
				
				@address = @address + (if (@reg[0] & 0x4) != 0 then 32 else 1)
				return ret	

	setReg: (addr, value) ->
		#console.log "set", addr.toString(16), value.toString(16)
		@reg[addr] = value

		switch addr
			when 0
				#console.log("set controller", value.toString(2))
				0
			when 1
				#console.log("set mask", value.toString(2))
				0
			when 3
				@oamAddr = value
			when 4
				#console.log "set oam", @oamAddr.toString(16), value.toString(16)
				@oam[@oamAddr] = value
				@oamAddr = (@oamAddr + 1) & 0xFF
			when 5
				console.log "set scroll", value
				if @firstScroll
					@scrollX = value
				else
					@scrollY = value

				@firstScroll = not @firstScroll

			when 6
				if @firstAddr
					@address = (value << 8) | (@address & 0xFF)
				else
					@address = (value) | (@address & 0xFF00)

				@firstAddr = not @firstAddr
				#console.log "set address", value.toString(16), @address.toString(16)

			when 7
				#console.log "set vram", @address.toString(16), value.toString(16)
				@setVRam(@address, value)
				@address = @address + (if (@reg[0] & 0x4) == 0 then 1 else 32)

	oamDma: (value) ->

		value = value << 8
		@oam[(@oamAddr + i) & 0xFF] = @ram.get(value | i) for i in [0...0x100]

	debugSprite: (offset) ->

		sprite = {}

		sprite.x = @oam[(offset*4) + 3]
		sprite.y = @oam[(offset*4)] + 1

		palette = @getPalette(@oam[(offset*4) + 2] & 0x3, true)
		sprite.tile = @getTile(@oam[(offset*4) + 1], palette, true)

		return sprite

	debugNameTable: (row, col) ->
		address = 0x2000 + ((@reg[0] & 0x3) * 0x400)
		nameTable = @getVRam(address + (row*32) + col)

		attributeValue = @getVRam(address + 0x3C0 + (Math.floor(row/4)*8) + Math.floor(col/4))
		attribute = null

		if row%4 < 2 and col%4 < 2
			attribute = attributeValue & 0x3
		else if row%4 < 2 and col%4 >= 2
			attribute = (attributeValue >> 2) & 0x3
		else if row%4 >= 2 and col%4 < 2
			attribute = (attributeValue >> 4) & 0x3
		else if row%4 >= 2 and col%4 >= 2
			attribute = (attributeValue >> 6) & 0x3

		palette = @getPalette(attribute)

		tile = @getTile(nameTable, palette)

		# console.log(row, col, nameTable, attribute, tile, palette)

		return tile

	debugScanLine: (y) ->
		row = Math.floor(y/8)
		offset = y%8
		ret = (0 for [1..256])
		background = @colors[@getVRam(0x3F00)]

		if (@reg[1] & 0x08) != 0
			for col in [0...32]
				tile = @debugNameTable(row, col)
				for x in [0...8]
					ret[(col*8) + x + @scrollX] = tile[offset][x]

		if (@reg[1] & 0x10) != 0
			for i in [0...64]
				sprite = @debugSprite(i)
				if sprite.y <= y and sprite.y > (y-8)
					spriteOffset = (y - sprite.y)%8
					for x in [0...8]
						if i == 0 and ret[x + sprite.x] != background and sprite.tile[spriteOffset][x] != background
							@spriteHit = true
							console.log "sprite hit"
						ret[x + sprite.x + @scrollX] = sprite.tile[spriteOffset][x]

		return ret

	getTile: (tileNumber, palette, sprite = false) ->
		offset = 0
		if sprite
			offset = if (@reg[0] & 0x8) != 0 then 0x1000 else 0
		else
			offset = if (@reg[0] & 0x10) != 0 then 0x1000 else 0

		tile = []
		for i in [0...8] by 1
			h = @getVRam(offset + (tileNumber*16) + i)
			l = @getVRam(offset + (tileNumber*16) + i + 8)
			tile[i] = []
			for b in [0...8] by 1
				value = if (h & (1 << b)) == 0 then 0 else 2
				value += if (l & (1 << b)) == 0 then  0 else 1
				tile[i][7-b] = @colors[palette[value]];

			#console.log(i + '|', tile[i][7], tile[i][6], tile[i][5], tile[i][4],
			#	tile[i][3], tile[i][2], tile[i][1], tile[i][0])

		return tile

	getPalette: (number, sprite = false) ->
		colors = []
		colors[0] = @getVRam(0x3F00)

		colors[i] = @getVRam((if sprite then 0x3F10 else 0x3F00) + (4*number) + i) for i in [1..3]

		return colors
