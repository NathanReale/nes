window.Ops =

	# ADC - Add with Carry
	0x69: { cmd: 'ADC', addr: 'imm', bytes: 2, cycles: 2 }
	0x65: { cmd: 'ADC', addr: 'zp', bytes: 2, cycles: 3 }
	0x75: { cmd: 'ADC', addr: 'zpx', bytes: 2, cycles: 4 }
	0x6D: { cmd: 'ADC', addr: 'abs', bytes: 3, cycles: 4 }
	0x7D: { cmd: 'ADC', addr: 'absx', bytes: 3, cycles: 4 }
	0x79: { cmd: 'ADC', addr: 'absy', bytes: 3, cycles: 4 }
	0x61: { cmd: 'ADC', addr: 'indx', bytes: 2, cycles: 6 }
	0x71: { cmd: 'ADC', addr: 'indy', bytes: 2, cycles: 5 }

	# AND - Logical AND
	0x29: { cmd: 'AND', addr: 'imm', bytes: 2, cycles: 2 }
	0x25: { cmd: 'AND', addr: 'zp', bytes: 2, cycles: 3 }
	0x35: { cmd: 'AND', addr: 'zpx', bytes: 2, cycles: 4 }
	0x2D: { cmd: 'AND', addr: 'abs', bytes: 3, cycles: 4 }
	0x3D: { cmd: 'AND', addr: 'absx', bytes: 3, cycles: 4 }
	0x39: { cmd: 'AND', addr: 'absy', bytes: 3, cycles: 4 }
	0x21: { cmd: 'AND', addr: 'indx', bytes: 2, cycles: 6 }
	0x31: { cmd: 'AND', addr: 'indy', bytes: 2, cycles: 5 }

	# ASL - Arithmetic Shift Left
	0x0A:  { cmd: 'ASL', addr: 'acc', bytes: 1, cycles: 2 }
	0x06:  { cmd: 'ASL', addr: 'zp', bytes: 2, cycles: 5 }
	0x16:  { cmd: 'ASL', addr: 'zpx', bytes: 2, cycles: 6 }
	0x0E:  { cmd: 'ASL', addr: 'abs', bytes: 3, cycles: 6 }
	0x1E:  { cmd: 'ASL', addr: 'absx', bytes: 3, cycles: 7 }

	# BCC - Branch if Carry Clear
	0x90: { cmd: 'BCC', addr: 'rel', bytes: 2, cycles: 2 }

	# BCS - Branch if Carry Set
	0xB0: { cmd: 'BCS', addr: 'rel', bytes: 2, cycles: 2 }

	# BEQ - Branch if Equal
	0xF0: { cmd: 'BEQ', addr: 'rel', bytes: 2, cycles: 2 }

	# BIT - Bit Test
	0x24: { cmd: 'BIT', addr: 'zp', bytes: 2, cycles: 3 }
	0x2C: { cmd: 'BIT', addr: 'abs', bytes: 3, cycles: 4 }

	# BMI - Branch if Minus
	0x30: { cmd: 'BMI', addr: 'rel', bytes: 2, cycles: 2 }

	# BNE - Branch if Not Equal
	0xD0: { cmd: 'BNE', addr: 'rel', bytes: 2, cycles: 2 }

	# BPL - Branch if Positive
	0x10: { cmd: 'BPL', addr: 'rel', bytes: 2, cycles: 2 }

	# BRK - Force Interrupt
	0x00: { cmd: 'BRK', addr: 'imp', bytes: 1, cycles: 7 }

	# BVC - Branch if Overflow Clear
	0x50: { cmd: 'BVC', addr: 'rel', bytes: 2, cycles: 2 }

	# BVS - Branch if Overflow Set
	0x70: { cmd: 'BVS', addr: 'rel', bytes: 2, cycles: 2 }

	# CLC - Clear Carry Flag
	0x18: { cmd: 'CLC', addr: 'imp', bytes: 1, cycles: 2 }

	# CLD - CLear Decimal Mode
	0xD8: { cmd: 'CLD', addr: 'imp', bytes: 1, cycles: 2 }

	# CLI - CLear Interrupt Disable
	0x58: { cmd: 'CLI', addr: 'imp', bytes: 1, cycles: 2 }

	# CLV - CLear Overflow Flag
	0xB8: { cmd: 'CLV', addr: 'imp', bytes: 1, cycles: 2 }

	# CMP - Compare
	0xC9: { cmd: 'CMP', addr: 'imm', bytes: 2, cycles: 2 }
	0xC5: { cmd: 'CMP', addr: 'zp', bytes: 2, cycles: 3 }
	0xD5: { cmd: 'CMP', addr: 'zpx', bytes: 2, cycles: 4 }
	0xCD: { cmd: 'CMP', addr: 'abs', bytes: 3, cycles: 4 }
	0xDD: { cmd: 'CMP', addr: 'absx', bytes: 3, cycles: 4 }
	0xD9: { cmd: 'CMP', addr: 'absy', bytes: 3, cycles: 4 }
	0xC1: { cmd: 'CMP', addr: 'indx', bytes: 2, cycles: 6 }
	0xD1: { cmd: 'CMP', addr: 'indy', bytes: 2, cycles: 5 }

	# CPX - Compare X Register
	0xE0: { cmd: 'CPX', addr: 'imm', bytes: 2, cycles: 2 }
	0xE4: { cmd: 'CPX', addr: 'zp', bytes: 2, cycles: 3 }
	0xEC: { cmd: 'CPX', addr: 'abs', bytes: 3, cycles: 4 }

	# CPY - Compare Y Register
	0xC0: { cmd: 'CPY', addr: 'imm', bytes: 2, cycles: 2 }
	0xC4: { cmd: 'CPY', addr: 'zp', bytes: 2, cycles: 3 }
	0xCC: { cmd: 'CPY', addr: 'abs', bytes: 3, cycles: 4 }

	# DEC - Decrement Memory
	0xC6: { cmd: 'DEC', addr: 'zp', bytes: 2, cycles: 5 }
	0xD6: { cmd: 'DEC', addr: 'zpx', bytes: 2, cycles: 6 }
	0xCE: { cmd: 'DEC', addr: 'abs', bytes: 3, cycles: 6 }
	0xDE: { cmd: 'DEC', addr: 'absx', bytes: 3, cycles: 7 }

	# DEX - Decrement X Register
	0xCA: { cmd: 'DEX', addr: 'imp', bytes: 1, cycles: 2 }

	# DEY - Decrement Y Register
	0x88: { cmd: 'DEY', addr: 'imp', bytes: 1, cycles: 2 }

	#EOR - Exclusive OR
	0x49: { cmd: 'EOR', addr: 'imm', bytes: 2, cycles: 2 }
	0x45: { cmd: 'EOR', addr: 'zp', bytes: 2, cycles: 3 }
	0x55: { cmd: 'EOR', addr: 'zpx', bytes: 2, cycles: 4 }
	0x4D: { cmd: 'EOR', addr: 'abs', bytes: 3, cycles: 4 }
	0x5D: { cmd: 'EOR', addr: 'absx', bytes: 3, cycles: 4 }
	0x59: { cmd: 'EOR', addr: 'absy', bytes: 3, cycles: 4 }
	0x41: { cmd: 'EOR', addr: 'indx', bytes: 2, cycles: 6 }
	0x51: { cmd: 'EOR', addr: 'indy', bytes: 2, cycles: 5 }

	# INC - Increment Memory
	0xE6: { cmd: 'INC', addr: 'zp', bytes: 2, cycles: 5 }
	0xF6: { cmd: 'INC', addr: 'zpx', bytes: 2, cycles: 6 }
	0xEE: { cmd: 'INC', addr: 'abs', bytes: 3, cycles: 6 }
	0xFE: { cmd: 'INC', addr: 'absx', bytes: 3, cycles: 7 }

	# INX - Increment X Register
	0xE8: { cmd: 'INX', addr: 'imp', bytes: 1, cycles: 2 }

	# INY - Increment Y Register
	0xC8: { cmd: 'INY', addr: 'imp', bytes: 1, cycles: 2 }

	# JMP - Jump
	0x4C: { cmd: 'JMP', addr: 'abs', bytes: 3, cycles: 3 }
	0x6C: { cmd: 'JMP', addr: 'ind', bytes: 3, cycles: 5 }

	# JSR - Jump to Subroutine
	0x20: { cmd: 'JSR', addr: 'abs', bytes: 3, cycles: 6 }

	# LDA - Load Accumulator
	0xA9: { cmd: 'LDA', addr: 'imm', bytes: 2, cycles: 2 }
	0xA5: { cmd: 'LDA', addr: 'zp', bytes: 2, cycles: 3 }
	0xB5: { cmd: 'LDA', addr: 'zpx', bytes: 2, cycles: 4 }
	0xAD: { cmd: 'LDA', addr: 'abs', bytes: 3, cycles: 4 }
	0xBD: { cmd: 'LDA', addr: 'absx', bytes: 3, cycles: 4 }
	0xB9: { cmd: 'LDA', addr: 'absy', bytes: 3, cycles: 4 }
	0xA1: { cmd: 'LDA', addr: 'indx', bytes: 2, cycles: 6 }
	0xB1: { cmd: 'LDA', addr: 'indy', bytes: 2, cycles: 5 }

	# LDX - Load X Register
	0xA2: { cmd: 'LDX', addr: 'imm', bytes: 2, cycles: 2 }
	0xA6: { cmd: 'LDX', addr: 'zp', bytes: 2, cycles: 3 }
	0xB6: { cmd: 'LDX', addr: 'zpy', bytes: 2, cycles: 4 }
	0xAE: { cmd: 'LDX', addr: 'abs', bytes: 3, cycles: 4 }
	0xBE: { cmd: 'LDX', addr: 'absy', bytes: 3, cycles: 4 }

	# LDY - Load Y Register
	0xA0: { cmd: 'LDY', addr: 'imm', bytes: 2, cycles: 2 }
	0xA4: { cmd: 'LDY', addr: 'zp', bytes: 2, cycles: 3 }
	0xB4: { cmd: 'LDY', addr: 'zpx', bytes: 2, cycles: 3 }
	0xAC: { cmd: 'LDY', addr: 'abs', bytes: 3, cycles: 4 }
	0xBC: { cmd: 'LDY', addr: 'absx', bytes: 3, cycles: 4 }

	# LSR - Logical Shift Right
	0x4A: { cmd: 'LSR', addr: 'acc', bytes: 1, cycles: 2 }
	0x46: { cmd: 'LSR', addr: 'zp', bytes: 2, cycles: 5 }
	0x56: { cmd: 'LSR', addr: 'zpx', bytes: 2, cycles: 6 }
	0x4E: { cmd: 'LSR', addr: 'abs', bytes: 3, cycles: 6 }
	0x5E: { cmd: 'LSR', addr: 'absx', bytes: 3, cycles: 7 }

	# NOP - No Operation
	0xEA: { cmd: 'NOP', addr: 'imp', bytes: 1, cycles: 2 }

	# ORA - Logical Inclusive OR
	0x09: { cmd: 'ORA', addr: 'imm', bytes: 2, cycles: 2 }
	0x05: { cmd: 'ORA', addr: 'zp', bytes: 2, cycles: 3 }
	0x15: { cmd: 'ORA', addr: 'zpx', bytes: 2, cycles: 4 }
	0x0D: { cmd: 'ORA', addr: 'abs', bytes: 3, cycles: 4 }
	0x1D: { cmd: 'ORA', addr: 'absx', bytes: 3, cycles: 4 }
	0x19: { cmd: 'ORA', addr: 'absy', bytes: 3, cycles: 4 }
	0x01: { cmd: 'ORA', addr: 'indx', bytes: 2, cycles: 6 }
	0x11: { cmd: 'ORA', addr: 'indy', bytes: 2, cycles: 5 }

	# PHA - Push Accumulator
	0x48: { cmd: 'PHA', addr: 'imp', bytes: 1, cycles: 3 }

	# PHP - Push Processor Status
	0x08: { cmd: 'PHP', addr: 'imp', bytes: 1, cycles: 3 }

	# PLA - Pull Accumulator
	0x68: { cmd: 'PLA', addr: 'imp', bytes: 1, cycles: 4 }

	# PLP - Pull Processor Status
	0x28: { cmd: 'PLP', addr: 'imp', bytes: 1, cycles: 4 }

	# ROL - Rotate Left
	0x2A: { cmd: 'ROL', addr: 'acc', bytes: 1, cycles: 2 }
	0x26: { cmd: 'ROL', addr: 'zp', bytes: 2, cycles: 5 }
	0x36: { cmd: 'ROL', addr: 'zpx', bytes: 2, cycles: 6 }
	0x2E: { cmd: 'ROL', addr: 'abs', bytes: 3, cycles: 6 }
	0x3E: { cmd: 'ROL', addr: 'absx', bytes: 3, cycles: 7 }

	# ROR - Rotate Right
	0x6A: { cmd: 'ROR', addr: 'acc', bytes: 1, cycles: 2 }
	0x66: { cmd: 'ROR', addr: 'zp', bytes: 2, cycles: 5 }
	0x76: { cmd: 'ROR', addr: 'zpx', bytes: 2, cycles: 6 }
	0x6E: { cmd: 'ROR', addr: 'abs', bytes: 3, cycles: 6 }
	0x7E: { cmd: 'ROR', addr: 'absx', bytes: 3, cycles: 7 }

	# RTI - Return from Interrupt
	0x40: { cmd: 'RTI', addr: 'imp', bytes: 1, cycles: 6 }

	# RTS - Return from Subroutine
	0x60: { cmd: 'RTS', addr: 'imp', bytes: 1, cycles: 6 }

	# SBC - Subtract with Carry
	0xE9: { cmd: 'SBC', addr: 'imm', bytes: 2, cycles: 2 }
	0xE5: { cmd: 'SBC', addr: 'zp', bytes: 2, cycles: 3 }
	0xF5: { cmd: 'SBC', addr: 'zpx', bytes: 2, cycles: 4 }
	0xED: { cmd: 'SBC', addr: 'abs', bytes: 3, cycles: 4 }
	0xFD: { cmd: 'SBC', addr: 'absx', bytes: 3, cycles: 4 }
	0xF9: { cmd: 'SBC', addr: 'absy', bytes: 3, cycles: 4 }
	0xE1: { cmd: 'SBC', addr: 'indx', bytes: 2, cycles: 6 }
	0xF1: { cmd: 'SBC', addr: 'indy', bytes: 2, cycles: 5 }

	# SEC - Set Carry Flag
	0x38: { cmd: 'SEC', addr: 'imp', bytes: 1, cycles: 2 }

	# SED - Set Decimal Flag
	0xF8: { cmd: 'SED', addr: 'imp', bytes: 1, cycles: 2 }

	# SEI - Set Interrupt Disable
	0x78: { cmd: 'SEI', addr: 'imp', bytes: 1, cycles: 2 }

	# STA - Store Accumulator
	0x85: { cmd: 'STA', addr: 'zp', bytes: 2, cycles: 3 }
	0x95: { cmd: 'STA', addr: 'zpx', bytes: 2, cycles: 4 }
	0x8D: { cmd: 'STA', addr: 'abs', bytes: 3, cycles: 4 }
	0x9D: { cmd: 'STA', addr: 'absx', bytes: 3, cycles: 5 }
	0x99: { cmd: 'STA', addr: 'absy', bytes: 3, cycles: 5 }
	0x81: { cmd: 'STA', addr: 'indx', bytes: 2, cycles: 6 }
	0x91: { cmd: 'STA', addr: 'indy', bytes: 2, cycles: 6 }

	# STX - Store X Register
	0x86: { cmd: 'STX', addr: 'zp', bytes: 2, cycles: 3 }
	0x96: { cmd: 'STX', addr: 'zpy', bytes: 2, cycles: 4 }
	0x8E: { cmd: 'STX', addr: 'abs', bytes: 3, cycles: 4 }

	# STY - Store Y Register
	0x84: { cmd: 'STY', addr: 'zp', bytes: 2, cycles: 3 }
	0x94: { cmd: 'STY', addr: 'zpx', bytes: 2, cycles: 4 }
	0x8C: { cmd: 'STY', addr: 'abs', bytes: 3, cycles: 4 }

	# TAX - Transfer Accumulator to X
	0xAA: { cmd: 'TAX', addr: 'imp', bytes: 1, cycles: 2 }

	# TAY - Transfer Accumulator to Y
	0xA8: { cmd: 'TAY', addr: 'imp', bytes: 1, cycles: 2 }

	# TSX - Transfer Stack Pointer to X
	0xBA: { cmd: 'TSX', addr: 'imp', bytes: 1, cycles: 2 }

	# TXA - Transfer X to Accumulator
	0x8A: { cmd: 'TXA', addr: 'imp', bytes: 1, cycles: 2 }

	# TXS - Transfer X to Stack Pointer
	0x9A: { cmd: 'TXS', addr: 'imp', bytes: 1, cycles: 2 }

	# TYA - Transfer Y to Accumulator
	0x98: { cmd: 'TYA', addr: 'imp', bytes: 1, cycles: 2 }





	# Unofficial Op Codes

	# DCP - Decrement Memory without borrow
	0xC7: { cmd: 'DCP', addr: 'zp', bytes: 2, cycles: 5 }
	0xD7: { cmd: 'DCP', addr: 'zpx', bytes: 2, cycles: 6 }
	0xCF: { cmd: 'DCP', addr: 'abs', bytes: 3, cycles: 6 }
	0xDF: { cmd: 'DCP', addr: 'absx', bytes: 3, cycles: 7 }
	0xDB: { cmd: 'DCP', addr: 'absy', bytes: 3, cycles: 7 }
	0xC3: { cmd: 'DCP', addr: 'indx', bytes: 2, cycles: 8 }
	0xD3: { cmd: 'DCP', addr: 'indy', bytes: 2, cycles: 8 }

	# ISC - Increment Memory and subtract from accumulator
	0xE7: { cmd: 'ISC', addr: 'zp', bytes: 2, cycles: 5 }
	0xF7: { cmd: 'ISC', addr: 'zpx', bytes: 2, cycles: 6 }
	0xEF: { cmd: 'ISC', addr: 'abs', bytes: 3, cycles: 6 }
	0xFF: { cmd: 'ISC', addr: 'absx', bytes: 3, cycles: 7 }
	0xFB: { cmd: 'ISC', addr: 'absy', bytes: 3, cycles: 7 }
	0xE3: { cmd: 'ISC', addr: 'indx', bytes: 2, cycles: 8 }
	0xF3: { cmd: 'ISC', addr: 'indy', bytes: 2, cycles: 8 }

	# LAX - Load Accumulator and X Register
	0xA7: { cmd: 'LAX', addr: 'zp', bytes: 2, cycles: 3 }
	0xB7: { cmd: 'LAX', addr: 'zpy', bytes: 2, cycles: 4 }
	0xAF: { cmd: 'LAX', addr: 'abs', bytes: 3, cycles: 4 }
	0xBF: { cmd: 'LAX', addr: 'absy', bytes: 3, cycles: 4 }
	0xA3: { cmd: 'LAX', addr: 'indx', bytes: 2, cycles: 6 }
	0xB3: { cmd: 'LAX', addr: 'indy', bytes: 2, cycles: 5 }

	# NOP - Do nothing (may be used for side effects)
	0x1A: { cmd: 'NOP', addr: 'imp', bytes: 1, cycles: 2 }
	0x3A: { cmd: 'NOP', addr: 'imp', bytes: 1, cycles: 2 }
	0x5A: { cmd: 'NOP', addr: 'imp', bytes: 1, cycles: 2 }
	0x7A: { cmd: 'NOP', addr: 'imp', bytes: 1, cycles: 2 }
	0xDA: { cmd: 'NOP', addr: 'imp', bytes: 1, cycles: 2 }
	0xFA: { cmd: 'NOP', addr: 'imp', bytes: 1, cycles: 2 }
	0x04: { cmd: 'NOP', addr: 'zp', bytes: 2, cycles: 3 }
	0x44: { cmd: 'NOP', addr: 'zp', bytes: 2, cycles: 3 }
	0x64: { cmd: 'NOP', addr: 'zp', bytes: 2, cycles: 3 }
	0x14: { cmd: 'NOP', addr: 'zpx', bytes: 2, cycles: 4 }
	0x34: { cmd: 'NOP', addr: 'zpx', bytes: 2, cycles: 4 }
	0x54: { cmd: 'NOP', addr: 'zpx', bytes: 2, cycles: 4 }
	0x74: { cmd: 'NOP', addr: 'zpx', bytes: 2, cycles: 4 }
	0xD4: { cmd: 'NOP', addr: 'zpx', bytes: 2, cycles: 4 }
	0xF4: { cmd: 'NOP', addr: 'zpx', bytes: 2, cycles: 4 }
	0x80: { cmd: 'NOP', addr: 'imm', bytes: 2, cycles: 2 }
	0x82: { cmd: 'NOP', addr: 'imm', bytes: 2, cycles: 2 }
	0x89: { cmd: 'NOP', addr: 'imm', bytes: 2, cycles: 2 }
	0xC2: { cmd: 'NOP', addr: 'imm', bytes: 2, cycles: 2 }
	0xE2: { cmd: 'NOP', addr: 'imm', bytes: 2, cycles: 2 }
	0x0C: { cmd: 'NOP', addr: 'abs', bytes: 3, cycles: 4 }
	0x1C: { cmd: 'NOP', addr: 'absx', bytes: 3, cycles: 4 }
	0x3C: { cmd: 'NOP', addr: 'absx', bytes: 3, cycles: 4 }
	0x5C: { cmd: 'NOP', addr: 'absx', bytes: 3, cycles: 4 }
	0x7C: { cmd: 'NOP', addr: 'absx', bytes: 3, cycles: 4 }
	0xDC: { cmd: 'NOP', addr: 'absx', bytes: 3, cycles: 4 }
	0xFC: { cmd: 'NOP', addr: 'absx', bytes: 3, cycles: 4 }

	# RLA - Rotate memory left and AND with accumulator
	0x27: { cmd: 'RLA', addr: 'zp', bytes: 2, cycles: 5 }
	0x37: { cmd: 'RLA', addr: 'zpx', bytes: 2, cycles: 6 }
	0x2F: { cmd: 'RLA', addr: 'abs', bytes: 3, cycles: 6 }
	0x3F: { cmd: 'RLA', addr: 'absx', bytes: 3, cycles: 7 }
	0x3B: { cmd: 'RLA', addr: 'absy', bytes: 3, cycles: 7 }
	0x23: { cmd: 'RLA', addr: 'indx', bytes: 2, cycles: 8 }
	0x33: { cmd: 'RLA', addr: 'indy', bytes: 2, cycles: 8 }

	# RRA - Rotate memory right and add to accumulator
	0x67: { cmd: 'RRA', addr: 'zp', bytes: 2, cycles: 5 }
	0x77: { cmd: 'RRA', addr: 'zpx', bytes: 2, cycles: 6 }
	0x6F: { cmd: 'RRA', addr: 'abs', bytes: 3, cycles: 6 }
	0x7F: { cmd: 'RRA', addr: 'absx', bytes: 3, cycles: 7 }
	0x7B: { cmd: 'RRA', addr: 'absy', bytes: 3, cycles: 7 }
	0x63: { cmd: 'RRA', addr: 'indx', bytes: 2, cycles: 8 }
	0x73: { cmd: 'RRA', addr: 'indy', bytes: 2, cycles: 8 }

	# SAX - AND X Register with Accumulator and store in memory
	0x87: { cmd: 'SAX', addr: 'zp', bytes: 2, cycles: 3 }
	0x97: { cmd: 'SAX', addr: 'zpy', bytes: 2, cycles: 4 }
	0x83: { cmd: 'SAX', addr: 'indx', bytes: 2, cycles: 6 }
	0x8F: { cmd: 'SAX', addr: 'abs', bytes: 3, cycles: 4 }

	# SBC - Same as original
	0xEB: { cmd: 'SBC', addr: 'imm', bytes: 2, cycles: 2 }

	# SLO - Shift memory left and OR with accumulator
	0x07: { cmd: 'SLO', addr: 'zp', bytes: 2, cycles: 5 }
	0x17: { cmd: 'SLO', addr: 'zpx', bytes: 2, cycles: 6 }
	0x0F: { cmd: 'SLO', addr: 'abs', bytes: 3, cycles: 6 }
	0x1F: { cmd: 'SLO', addr: 'absx', bytes: 3, cycles: 7 }
	0x1B: { cmd: 'SLO', addr: 'absy', bytes: 3, cycles: 7 }
	0x03: { cmd: 'SLO', addr: 'indx', bytes: 2, cycles: 8 }
	0x13: { cmd: 'SLO', addr: 'indy', bytes: 2, cycles: 8 }

	# SRE - Shift memory right and EOR with accumulator
	0x47: { cmd: 'SRE', addr: 'zp', bytes: 2, cycles: 5 }
	0x57: { cmd: 'SRE', addr: 'zpx', bytes: 2, cycles: 6 }
	0x4F: { cmd: 'SRE', addr: 'abs', bytes: 3, cycles: 6 }
	0x5F: { cmd: 'SRE', addr: 'absx', bytes: 3, cycles: 7 }
	0x5B: { cmd: 'SRE', addr: 'absy', bytes: 3, cycles: 7 }
	0x43: { cmd: 'SRE', addr: 'indx', bytes: 2, cycles: 8 }
	0x53: { cmd: 'SRE', addr: 'indy', bytes: 2, cycles: 8 }
