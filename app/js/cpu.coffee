class window.CPU
	constructor: (@ram, @reg, @printDebug = false) ->

		@status =
			carry: false
			zero: false
			interrupt: true
			decimal: false
			break: false
			overflow: false
			negative: false

		@debugCount = 1

	step: ->

		opCode = @ram.get(@reg.p.val)
		op = Ops[opCode]

		# Skip on unknown
		if op == undefined
			throw "Op " + opCode.toString(16) + " not known"
			#return false

		# Pull bytes from memory that this command uses
		bytes = (@ram.get(@reg.p.val+i) for i in [0...(op.bytes)])

		debugStr = ''
		if @printDebug
			debugStr = @reg.p.val.toString(16) + ' ' + (x.toString(16) for x in bytes).join(' ') + 
			 	('  ' for x in [op.bytes..3]).join(' ') + '\t ' + op.cmd + ' '

		# Get the address for this command, if applicable
		addr = switch op.addr
			when 'imp'
				null
			when 'acc'
				'A'
			when 'imm'
				@reg.p.val + 1
			when 'zp'
				bytes[1]
			when 'zpx'
				(bytes[1] + @reg.x.val) & 0xFF
			when 'zpy'
				(bytes[1] + @reg.y.val) & 0xFF
			when 'rel'
				@reg.p.val + toSigned(bytes[1]) + 2
			when 'abs'
				byteToAddr(bytes[1], bytes[2])
			when 'absx'
				(byteToAddr(bytes[1], bytes[2]) + @reg.x.val) & 0xFFFF
			when 'absy'
				(byteToAddr(bytes[1], bytes[2]) + @reg.y.val) & 0xFFFF
			when 'ind'
				temp = byteToAddr(bytes[1], bytes[2])
				byteToAddr(@ram.get(temp), @ram.get((temp & 0xFF00) | (temp+1) & 0xFF))
			when 'indx'
				byteToAddr(@ram.get((bytes[1] + @reg.x.val) & 0xFF),
					@ram.get((bytes[1] + @reg.x.val + 1) & 0xFF))
			when 'indy'
				(byteToAddr(@ram.get(bytes[1]), @ram.get((bytes[1] + 1) & 0xFF)) + @reg.y.val) & 0xFFFF
			else
				#null
				throw "Address " + op.addr + " not implemented."
			

		# Increment Program Counter - Only matters if there is no jump/branch
		@reg.p.add(op.bytes)

		if @printDebug
			debugStr += (if addr != null then addr.toString(16) else ' ') + '  \t'
			@debug(debugStr)

		# Perform the command
		switch op.cmd
			when 'ADC'
				value = @ram.get(addr)
				@reg.a.add(value, @status.carry)

				@status.carry = @reg.a.carry
				@status.zero = @reg.a.zero
				@status.overflow = @reg.a.overflow
				@status.negative = @reg.a.neg
			when 'AND'
				value = @ram.get(addr)
				@reg.a.set(@reg.a.val & value)
				@status.zero = @reg.a.zero
				@status.negative = @reg.a.neg
			when 'ASL'
				if addr == 'A'
					@reg.a.shiftLeft()
					@status.carry = @reg.a.carry
					@status.zero = @reg.a.zero
					@status.negative = @reg.a.neg
				else
					temp = @ram.get(addr)
					@status.carry = (temp & 0x80) != 0
					temp = (temp << 1) & 0xFF
					@status.zero = (temp == 0)
					@status.negative = (temp & 0x80) != 0
					@ram.set(addr, temp)
			when 'BCC'
				if not @status.carry
					@reg.p.set(addr)
			when 'BCS'
				if @status.carry
					@reg.p.set(addr)
			when 'BEQ'
				if @status.zero
					@reg.p.set(addr)
			when 'BIT'			
				value = @ram.get(addr)
				@status.zero = (@reg.a.val & value) == 0
				@status.overflow = (value & 0x40) != 0
				@status.negative = (value & 0x80) != 0
			when 'BMI'
				if @status.negative
					@reg.p.set(addr)
			when 'BNE'
				if not @status.zero
					@reg.p.set(addr)
			when 'BPL'
				if not @status.negative
					@reg.p.set(addr)
			when 'BRK'
				# This is ignored on the NES
				return false
			when 'BVC'
				if not @status.overflow
					@reg.p.set(addr)
			when 'BVS'
				if @status.overflow
					@reg.p.set(addr)
			when 'CLC'
				@status.carry = false
			when 'CLV'
				@status.overflow = false
			when 'CLD'
				@status.decimal = false
			when 'CMP'
				value = @ram.get(addr)
				@status.carry = @reg.a.val >= value
				temp = (@reg.a.val - value + 0x100) & 0xFF
				@status.zero = (temp == 0)
				@status.negative = (temp > 0x7F)
			when 'CPX'
				value = @ram.get(addr)
				temp = (@reg.x.val - value + 0x100) & 0xFF
				@status.carry = (temp <= 0x80)
				@status.zero = (temp == 0)
				@status.negative = (temp > 0x7F)
			when 'CPY'
				value = @ram.get(addr)
				temp = (@reg.y.val - value + 0x100) & 0xFF
				@status.carry = (temp <= 0x80)
				@status.zero = (temp == 0)
				@status.negative = (temp > 0x7F)
			when 'DEC'
				temp = @ram.get(addr)
				temp = ((temp + 0x100) - 1) & 0xFF
				@status.zero = temp == 0
				@status.negative = (temp & 0x80) != 0
				@ram.set(addr, temp)
			when 'DEX'
				@reg.x.sub(1)
				@status.zero = @reg.x.zero
				@status.negative = @reg.x.neg
			when 'DEY'
				@reg.y.sub(1)
				@status.zero = @reg.y.zero
				@status.negative = @reg.y.neg
			when 'EOR'
				value = @ram.get(addr)
				@reg.a.set(@reg.a.val ^ value)
				@status.zero = @reg.a.zero
				@status.negative = @reg.a.neg
			when 'INC'
				temp = @ram.get(addr)
				temp = (temp+1) & 0xFF
				@status.zero = temp == 0
				@status.negative = (temp & 0x80) != 0
				@ram.set(addr, temp)
			when 'INX'
				@reg.x.add(1)
				@status.zero = @reg.x.zero
				@status.negative = @reg.x.neg
			when 'INY'
				@reg.y.add(1)
				@status.zero = @reg.y.zero
				@status.negative = @reg.y.neg
			when 'JMP'
				@reg.p.set(addr)
			when 'JSR'
				newAddr = @reg.p.val - 1
				@pushStack(newAddr >> 8)
				@pushStack(newAddr & 0xFF)
				@reg.p.set(addr)
			when 'LDA'
				value = @ram.get(addr)
				@reg.a.set(value)
				@status.zero = @reg.a.zero
				@status.negative = @reg.a.neg
			when 'LDX'
				value = @ram.get(addr)
				@reg.x.set(value)
				@status.zero = @reg.x.zero
				@status.negative = @reg.x.neg
			when 'LDY'
				value = @ram.get(addr)
				@reg.y.set(value)
				@status.zero = @reg.y.zero
				@status.negative = @reg.y.neg
			when 'LSR'
				if addr == 'A'
					@reg.a.shiftRight()
					@status.carry = @reg.a.carry
					@status.zero = @reg.a.zero
					@status.negative = @reg.a.neg
				else
					temp = @ram.get(addr)
					@status.carry = (temp & 0x1) != 0
					temp = temp >> 1
					@status.zero = (temp == 0)
					@status.negative = false;
					@ram.set(addr, temp)
			when 'NOP'
				0 # Do nothing
			when 'ORA'
				value = @ram.get(addr)
				@reg.a.set(@reg.a.val | value)
				@status.zero = @reg.a.zero
				@status.negative = @reg.a.neg
			when 'PHA'
				@pushStack @reg.a.val
			when 'PHP'
				@pushStack(@statusRegister(true))
			when 'PLA'
				@reg.a.set(@popStack())
				@status.zero = @reg.a.zero
				@status.negative = @reg.a.neg
			when 'PLP'
				@setStatus @popStack()
			when 'ROL'
				if addr == 'A'
					@reg.a.shiftLeft(@status.carry)
					@status.carry = @reg.a.carry
					@status.zero = @reg.a.zero
					@status.negative = @reg.a.neg
				else
					temp = @ram.get(addr)
					oldCarry = if @status.carry then 0x01 else 0x0
					@status.carry = (temp & 0x80) != 0
					temp = ((temp << 1) & 0xFF) | oldCarry
					@status.zero = (temp == 0)
					@status.negative = (temp & 0x80) != 0
					@ram.set(addr, temp)
			when 'ROR'
				if addr == 'A'
					@reg.a.shiftRight(@status.carry)
					@status.carry = @reg.a.carry
					@status.zero = @reg.a.zero
					@status.negative = @reg.a.neg
				else
					temp = @ram.get(addr)
					oldCarry = if @status.carry then 0x80 else 0x0
					@status.negative = @status.carry;
					@status.carry = (temp & 0x1) != 0
					temp = (temp >> 1) | oldCarry
					@status.zero = (temp == 0)
					@ram.set(addr, temp)
			when 'RTI'
				@setStatus @popStack()
				@reg.p.set byteToAddr(@popStack(), @popStack())
			when 'RTS'
				@reg.p.set(byteToAddr(@popStack(), @popStack()))
				@reg.p.add(1)
			when 'SBC'
				value = @ram.get(addr)
				@reg.a.sub(value, not @status.carry)
				@status.carry = @reg.a.val < 0x80
				@status.zero = @reg.a.zero
				@status.overflow = @reg.a.overflow
				@status.negative = @reg.a.neg
			when 'SEC'
				@status.carry = true
			when 'SED'
				@status.decimal = true
			when 'SEI'
				@status.interrupt = true
			when 'STA'
				@ram.set(addr, @reg.a.val)
			when 'STX'
				@ram.set(addr, @reg.x.val)
			when 'STY'
				@ram.set(addr, @reg.y.val)
			when 'TAX'
				@reg.x.set(@reg.a.val)
				@status.zero = @reg.x.zero
				@status.negative = @reg.x.neg
			when 'TAY'
				@reg.y.set(@reg.a.val)
				@status.zero = @reg.y.zero
				@status.negative = @reg.y.neg
			when 'TSX'
				@reg.x.set(@reg.s.val)
				@status.zero = @reg.x.zero
				@status.negative = @reg.x.neg
			when 'TXA'
				@reg.a.set(@reg.x.val)
				@status.zero = @reg.a.zero
				@status.negative = @reg.a.neg
			when 'TXS'
				@reg.s.set(@reg.x.val)
			when 'TYA'
				@reg.a.set(@reg.y.val)
				@status.zero = @reg.a.zero
				@status.negative = @reg.a.neg


			# Unofficial Opcodes
			when 'DCP'
				value = ((@ram.get(addr) + 0x100) - 1) & 0xFF
				@ram.set(addr, value)

				@status.carry = @reg.a.val >= value
				temp = (@reg.a.val - value + 0x100) & 0xFF
				@status.zero = (temp == 0)
				@status.negative = (temp > 0x7F)
			when 'ISC'
				value = (@ram.get(addr) + 1) & 0xFF
				@ram.set(addr, value)

				@reg.a.sub(value, not @status.carry)
				@status.carry = @reg.a.val >= 0x80
				@status.zero = @reg.a.zero
				@status.overflow = @reg.a.overflow
				@status.negative = @reg.a.neg
			when 'LAX'
				value = @ram.get(addr)
				@reg.a.set(value)
				@reg.x.set(value)
				@status.zero = @reg.a.zero
				@status.negative = @reg.a.neg
			when 'RLA'
				value = @ram.get(addr)
				oldCarry = if @status.carry then 0x01 else 0x0
				@status.carry = (value & 0x80) != 0
				value = ((value << 1) & 0xFF) | oldCarry
				@ram.set(addr, value)

				@reg.a.set(@reg.a.val & value)
				@status.zero = @reg.a.zero
				@status.negative = @reg.a.neg
			when 'RRA'
				value = @ram.get(addr)
				oldCarry = if @status.carry then 0x80 else 0x0
				@status.carry = (value & 0x01) != 0
				value = (value >> 1) | oldCarry
				@ram.set(addr, value)

				@reg.a.add(value, @status.carry)
				@status.zero = @reg.a.zero
				@status.negative = @reg.a.neg
				@status.carry = @reg.a.carry
				@status.overflow = @reg.a.overflow
			when 'SAX'
				temp = @reg.a.val & @reg.x.val
				@ram.set(addr, temp)
			when 'SLO'
				value = @ram.get(addr)
				@status.carry = (value & 0x80) != 0
				value = (value << 1) & 0xFF
				@ram.set(addr, value)

				@reg.a.set(@reg.a.val | value)
				@status.zero = @reg.a.zero
				@status.negative = @reg.a.neg
			when 'SRE'
				value = @ram.get(addr)
				@status.carry = (value & 0x01) != 0
				value = value >> 1
				@ram.set(addr, value)

				@reg.a.set(@reg.a.val ^ value)
				@status.zero = @reg.a.zero
				@status.negative = @reg.a.neg

			else
				#null
				throw "Op " + op.cmd + " not implemented."


		return op.cycles

	pushStack: (value) ->
		@ram.set(@reg.s.val + 0x100, value)
		@reg.s.add(-1)

	popStack: ->
		@reg.s.add(1)
		val = @ram.get(@reg.s.val + 0x100)
		return val

	# pass true if this is from an instruction
	# This will set bit 4 to true
	statusRegister: (inst = false) ->
		total = 1 << 5

		total += 1 << 0 if @status.carry
		total += 1 << 1 if @status.zero
		total += 1 << 2 if @status.interrupt
		total += 1 << 3 if @status.decimal
		total += 1 << 4 if inst
		total += 1 << 6 if @status.overflow
		total += 1 << 7 if @status.negative

		return total

	setStatus: (flags) ->
		@status.carry = (flags & 1<<0) != 0
		@status.zero = (flags & 1<<1) != 0
		@status.interrupt = (flags & 1<<2) != 0
		@status.decimal = (flags & 1<<3) != 0
		@status.break = (flags & 1<<4) != 0
		@status.overflow = (flags & 1<<6) != 0
		@status.negative = (flags & 1<<7) != 0

	triggerIRQ: ->
		@pushStack(@reg.p.val >> 8)
		@pushStack(@reg.p.val & 0xFF)
		@pushStack(@statusRegister())
		@reg.p.set((@ram.get(0xFFFF) << 8) | @ram.get(0xFFFE))

	triggerNMI: ->
		@pushStack(@reg.p.val >> 8)
		@pushStack(@reg.p.val & 0xFF)
		@pushStack(@statusRegister())
		@reg.p.set((@ram.get(0xFFFB) << 8) | @ram.get(0xFFFA))

	debug: (str) ->
		console.log "%d: %sA:%s X:%s Y:%s P: %s S:%s",
			@debugCount++
			(if arguments.length > 0 then str+' ' else ''),
			@reg.a.val.toString(16),
			@reg.x.val.toString(16),
			@reg.y.val.toString(16),
			@statusRegister().toString(16),
			@reg.s.val.toString(16)


