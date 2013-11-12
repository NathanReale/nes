(function() {
  window.CPU = (function() {
    function CPU(ram, reg, printDebug) {
      this.ram = ram;
      this.reg = reg;
      this.printDebug = printDebug != null ? printDebug : false;
      this.status = {
        carry: false,
        zero: false,
        interrupt: true,
        decimal: false,
        "break": false,
        overflow: false,
        negative: false
      };
      this.debugCount = 1;
    }

    CPU.prototype.step = function() {
      var addr, bytes, debugStr, i, newAddr, oldCarry, op, opCode, temp, value, x;
      opCode = this.ram.get(this.reg.p.val);
      op = Ops[opCode];
      if (op === void 0) {
        throw "Op " + opCode.toString(16) + " not known";
      }
      bytes = (function() {
        var _i, _ref, _results;
        _results = [];
        for (i = _i = 0, _ref = op.bytes; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          _results.push(this.ram.get(this.reg.p.val + i));
        }
        return _results;
      }).call(this);
      debugStr = this.reg.p.val.toString(16) + ' ' + ((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = bytes.length; _i < _len; _i++) {
          x = bytes[_i];
          _results.push(x.toString(16));
        }
        return _results;
      })()).join(' ') + ((function() {
        var _i, _ref, _results;
        _results = [];
        for (x = _i = _ref = op.bytes; _ref <= 3 ? _i <= 3 : _i >= 3; x = _ref <= 3 ? ++_i : --_i) {
          _results.push('  ');
        }
        return _results;
      })()).join(' ') + '\t ' + op.cmd + ' ';
      addr = (function() {
        switch (op.addr) {
          case 'imp':
            return null;
          case 'acc':
            return 'A';
          case 'imm':
            return this.reg.p.val + 1;
          case 'zp':
            return bytes[1];
          case 'zpx':
            return (bytes[1] + this.reg.x.val) & 0xFF;
          case 'zpy':
            return (bytes[1] + this.reg.y.val) & 0xFF;
          case 'rel':
            return this.reg.p.val + toSigned(bytes[1]) + 2;
          case 'abs':
            return byteToAddr(bytes[1], bytes[2]);
          case 'absx':
            return (byteToAddr(bytes[1], bytes[2]) + this.reg.x.val) & 0xFFFF;
          case 'absy':
            return (byteToAddr(bytes[1], bytes[2]) + this.reg.y.val) & 0xFFFF;
          case 'ind':
            temp = byteToAddr(bytes[1], bytes[2]);
            return byteToAddr(this.ram.get(temp), this.ram.get((temp & 0xFF00) | (temp + 1) & 0xFF));
          case 'indx':
            return byteToAddr(this.ram.get((bytes[1] + this.reg.x.val) & 0xFF), this.ram.get((bytes[1] + this.reg.x.val + 1) & 0xFF));
          case 'indy':
            return (byteToAddr(this.ram.get(bytes[1]), this.ram.get((bytes[1] + 1) & 0xFF)) + this.reg.y.val) & 0xFFFF;
          default:
            throw "Address " + op.addr + " not implemented.";
        }
      }).call(this);
      this.reg.p.add(op.bytes);
      debugStr += (addr !== null ? addr.toString(16) : ' ') + '  \t';
      if (this.printDebug) {
        this.debug(debugStr);
      }
      switch (op.cmd) {
        case 'ADC':
          value = this.ram.get(addr);
          this.reg.a.add(value, this.status.carry);
          this.status.carry = this.reg.a.carry;
          this.status.zero = this.reg.a.zero;
          this.status.overflow = this.reg.a.overflow;
          this.status.negative = this.reg.a.neg;
          break;
        case 'AND':
          value = this.ram.get(addr);
          this.reg.a.set(this.reg.a.val & value);
          this.status.zero = this.reg.a.zero;
          this.status.negative = this.reg.a.neg;
          break;
        case 'ASL':
          if (addr === 'A') {
            this.reg.a.shiftLeft();
            this.status.carry = this.reg.a.carry;
            this.status.zero = this.reg.a.zero;
            this.status.negative = this.reg.a.neg;
          } else {
            temp = this.ram.get(addr);
            this.status.carry = (temp & 0x80) !== 0;
            temp = (temp << 1) & 0xFF;
            this.status.zero = temp === 0;
            this.status.negative = (temp & 0x80) !== 0;
            this.ram.set(addr, temp);
          }
          break;
        case 'BCC':
          if (!this.status.carry) {
            this.reg.p.set(addr);
          }
          break;
        case 'BCS':
          if (this.status.carry) {
            this.reg.p.set(addr);
          }
          break;
        case 'BEQ':
          if (this.status.zero) {
            this.reg.p.set(addr);
          }
          break;
        case 'BIT':
          value = this.ram.get(addr);
          this.status.zero = (this.reg.a.val & value) === 0;
          this.status.overflow = (value & 0x40) !== 0;
          this.status.negative = (value & 0x80) !== 0;
          break;
        case 'BMI':
          if (this.status.negative) {
            this.reg.p.set(addr);
          }
          break;
        case 'BNE':
          if (!this.status.zero) {
            this.reg.p.set(addr);
          }
          break;
        case 'BPL':
          if (!this.status.negative) {
            this.reg.p.set(addr);
          }
          break;
        case 'BRK':
          return false;
        case 'BVC':
          if (!this.status.overflow) {
            this.reg.p.set(addr);
          }
          break;
        case 'BVS':
          if (this.status.overflow) {
            this.reg.p.set(addr);
          }
          break;
        case 'CLC':
          this.status.carry = false;
          break;
        case 'CLV':
          this.status.overflow = false;
          break;
        case 'CLD':
          this.status.decimal = false;
          break;
        case 'CMP':
          value = this.ram.get(addr);
          this.status.carry = this.reg.a.val >= value;
          temp = (this.reg.a.val - value + 0x100) & 0xFF;
          this.status.zero = temp === 0;
          this.status.negative = temp > 0x7F;
          break;
        case 'CPX':
          value = this.ram.get(addr);
          temp = (this.reg.x.val - value + 0x100) & 0xFF;
          this.status.carry = temp <= 0x80;
          this.status.zero = temp === 0;
          this.status.negative = temp > 0x7F;
          break;
        case 'CPY':
          value = this.ram.get(addr);
          temp = (this.reg.y.val - value + 0x100) & 0xFF;
          this.status.carry = temp <= 0x80;
          this.status.zero = temp === 0;
          this.status.negative = temp > 0x7F;
          break;
        case 'DEC':
          temp = this.ram.get(addr);
          temp = ((temp + 0x100) - 1) & 0xFF;
          this.status.zero = temp === 0;
          this.status.negative = (temp & 0x80) !== 0;
          this.ram.set(addr, temp);
          break;
        case 'DEX':
          this.reg.x.sub(1);
          this.status.zero = this.reg.x.zero;
          this.status.negative = this.reg.x.neg;
          break;
        case 'DEY':
          this.reg.y.sub(1);
          this.status.zero = this.reg.y.zero;
          this.status.negative = this.reg.y.neg;
          break;
        case 'EOR':
          value = this.ram.get(addr);
          this.reg.a.set(this.reg.a.val ^ value);
          this.status.zero = this.reg.a.zero;
          this.status.negative = this.reg.a.neg;
          break;
        case 'INC':
          temp = this.ram.get(addr);
          temp = (temp + 1) & 0xFF;
          this.status.zero = temp === 0;
          this.status.negative = (temp & 0x80) !== 0;
          this.ram.set(addr, temp);
          break;
        case 'INX':
          this.reg.x.add(1);
          this.status.zero = this.reg.x.zero;
          this.status.negative = this.reg.x.neg;
          break;
        case 'INY':
          this.reg.y.add(1);
          this.status.zero = this.reg.y.zero;
          this.status.negative = this.reg.y.neg;
          break;
        case 'JMP':
          this.reg.p.set(addr);
          break;
        case 'JSR':
          newAddr = this.reg.p.val - 1;
          this.pushStack(newAddr >> 8);
          this.pushStack(newAddr & 0xFF);
          this.reg.p.set(addr);
          break;
        case 'LDA':
          value = this.ram.get(addr);
          this.reg.a.set(value);
          this.status.zero = this.reg.a.zero;
          this.status.negative = this.reg.a.neg;
          break;
        case 'LDX':
          value = this.ram.get(addr);
          this.reg.x.set(value);
          this.status.zero = this.reg.x.zero;
          this.status.negative = this.reg.x.neg;
          break;
        case 'LDY':
          value = this.ram.get(addr);
          this.reg.y.set(value);
          this.status.zero = this.reg.y.zero;
          this.status.negative = this.reg.y.neg;
          break;
        case 'LSR':
          if (addr === 'A') {
            this.reg.a.shiftRight();
            this.status.carry = this.reg.a.carry;
            this.status.zero = this.reg.a.zero;
            this.status.negative = this.reg.a.neg;
          } else {
            temp = this.ram.get(addr);
            this.status.carry = (temp & 0x1) !== 0;
            temp = temp >> 1;
            this.status.zero = temp === 0;
            this.status.negative = false;
            this.ram.set(addr, temp);
          }
          break;
        case 'NOP':
          0;
          break;
        case 'ORA':
          value = this.ram.get(addr);
          this.reg.a.set(this.reg.a.val | value);
          this.status.zero = this.reg.a.zero;
          this.status.negative = this.reg.a.neg;
          break;
        case 'PHA':
          this.pushStack(this.reg.a.val);
          break;
        case 'PHP':
          this.pushStack(this.statusRegister(true));
          break;
        case 'PLA':
          this.reg.a.set(this.popStack());
          this.status.zero = this.reg.a.zero;
          this.status.negative = this.reg.a.neg;
          break;
        case 'PLP':
          this.setStatus(this.popStack());
          break;
        case 'ROL':
          if (addr === 'A') {
            this.reg.a.shiftLeft(this.status.carry);
            this.status.carry = this.reg.a.carry;
            this.status.zero = this.reg.a.zero;
            this.status.negative = this.reg.a.neg;
          } else {
            temp = this.ram.get(addr);
            oldCarry = this.status.carry ? 0x01 : 0x0;
            this.status.carry = (temp & 0x80) !== 0;
            temp = ((temp << 1) & 0xFF) | oldCarry;
            this.status.zero = temp === 0;
            this.status.negative = (temp & 0x80) !== 0;
            this.ram.set(addr, temp);
          }
          break;
        case 'ROR':
          if (addr === 'A') {
            this.reg.a.shiftRight(this.status.carry);
            this.status.carry = this.reg.a.carry;
            this.status.zero = this.reg.a.zero;
            this.status.negative = this.reg.a.neg;
          } else {
            temp = this.ram.get(addr);
            oldCarry = this.status.carry ? 0x80 : 0x0;
            this.status.negative = this.status.carry;
            this.status.carry = (temp & 0x1) !== 0;
            temp = (temp >> 1) | oldCarry;
            this.status.zero = temp === 0;
            this.ram.set(addr, temp);
          }
          break;
        case 'RTI':
          this.setStatus(this.popStack());
          this.reg.p.set(byteToAddr(this.popStack(), this.popStack()));
          break;
        case 'RTS':
          this.reg.p.set(byteToAddr(this.popStack(), this.popStack()));
          this.reg.p.add(1);
          break;
        case 'SBC':
          value = this.ram.get(addr);
          this.reg.a.sub(value, !this.status.carry);
          this.status.carry = this.reg.a.val < 0x80;
          this.status.zero = this.reg.a.zero;
          this.status.overflow = this.reg.a.overflow;
          this.status.negative = this.reg.a.neg;
          break;
        case 'SEC':
          this.status.carry = true;
          break;
        case 'SED':
          this.status.decimal = true;
          break;
        case 'SEI':
          this.status.interrupt = true;
          break;
        case 'STA':
          this.ram.set(addr, this.reg.a.val);
          break;
        case 'STX':
          this.ram.set(addr, this.reg.x.val);
          break;
        case 'STY':
          this.ram.set(addr, this.reg.y.val);
          break;
        case 'TAX':
          this.reg.x.set(this.reg.a.val);
          this.status.zero = this.reg.x.zero;
          this.status.negative = this.reg.x.neg;
          break;
        case 'TAY':
          this.reg.y.set(this.reg.a.val);
          this.status.zero = this.reg.y.zero;
          this.status.negative = this.reg.y.neg;
          break;
        case 'TSX':
          this.reg.x.set(this.reg.s.val);
          this.status.zero = this.reg.x.zero;
          this.status.negative = this.reg.x.neg;
          break;
        case 'TXA':
          this.reg.a.set(this.reg.x.val);
          this.status.zero = this.reg.a.zero;
          this.status.negative = this.reg.a.neg;
          break;
        case 'TXS':
          this.reg.s.set(this.reg.x.val);
          break;
        case 'TYA':
          this.reg.a.set(this.reg.y.val);
          this.status.zero = this.reg.a.zero;
          this.status.negative = this.reg.a.neg;
          break;
        case 'DCP':
          value = ((this.ram.get(addr) + 0x100) - 1) & 0xFF;
          this.ram.set(addr, value);
          this.status.carry = this.reg.a.val >= value;
          temp = (this.reg.a.val - value + 0x100) & 0xFF;
          this.status.zero = temp === 0;
          this.status.negative = temp > 0x7F;
          break;
        case 'ISC':
          value = (this.ram.get(addr) + 1) & 0xFF;
          this.ram.set(addr, value);
          this.reg.a.sub(value, !this.status.carry);
          this.status.carry = this.reg.a.val >= 0x80;
          this.status.zero = this.reg.a.zero;
          this.status.overflow = this.reg.a.overflow;
          this.status.negative = this.reg.a.neg;
          break;
        case 'LAX':
          value = this.ram.get(addr);
          this.reg.a.set(value);
          this.reg.x.set(value);
          this.status.zero = this.reg.a.zero;
          this.status.negative = this.reg.a.neg;
          break;
        case 'RLA':
          value = this.ram.get(addr);
          oldCarry = this.status.carry ? 0x01 : 0x0;
          this.status.carry = (value & 0x80) !== 0;
          value = ((value << 1) & 0xFF) | oldCarry;
          this.ram.set(addr, value);
          this.reg.a.set(this.reg.a.val & value);
          this.status.zero = this.reg.a.zero;
          this.status.negative = this.reg.a.neg;
          break;
        case 'RRA':
          value = this.ram.get(addr);
          oldCarry = this.status.carry ? 0x80 : 0x0;
          this.status.carry = (value & 0x01) !== 0;
          value = (value >> 1) | oldCarry;
          this.ram.set(addr, value);
          this.reg.a.add(value, this.status.carry);
          this.status.zero = this.reg.a.zero;
          this.status.negative = this.reg.a.neg;
          this.status.carry = this.reg.a.carry;
          this.status.overflow = this.reg.a.overflow;
          break;
        case 'SAX':
          temp = this.reg.a.val & this.reg.x.val;
          this.ram.set(addr, temp);
          break;
        case 'SLO':
          value = this.ram.get(addr);
          this.status.carry = (value & 0x80) !== 0;
          value = (value << 1) & 0xFF;
          this.ram.set(addr, value);
          this.reg.a.set(this.reg.a.val | value);
          this.status.zero = this.reg.a.zero;
          this.status.negative = this.reg.a.neg;
          break;
        case 'SRE':
          value = this.ram.get(addr);
          this.status.carry = (value & 0x01) !== 0;
          value = value >> 1;
          this.ram.set(addr, value);
          this.reg.a.set(this.reg.a.val ^ value);
          this.status.zero = this.reg.a.zero;
          this.status.negative = this.reg.a.neg;
          break;
        default:
          throw "Op " + op.cmd + " not implemented.";
      }
      return true;
    };

    CPU.prototype.pushStack = function(value) {
      this.ram.set(this.reg.s.val + 0x100, value);
      return this.reg.s.add(-1);
    };

    CPU.prototype.popStack = function() {
      var val;
      this.reg.s.add(1);
      val = this.ram.get(this.reg.s.val + 0x100);
      return val;
    };

    CPU.prototype.statusRegister = function(inst) {
      var total;
      if (inst == null) {
        inst = false;
      }
      total = 1 << 5;
      if (this.status.carry) {
        total += 1 << 0;
      }
      if (this.status.zero) {
        total += 1 << 1;
      }
      if (this.status.interrupt) {
        total += 1 << 2;
      }
      if (this.status.decimal) {
        total += 1 << 3;
      }
      if (inst) {
        total += 1 << 4;
      }
      if (this.status.overflow) {
        total += 1 << 6;
      }
      if (this.status.negative) {
        total += 1 << 7;
      }
      return total;
    };

    CPU.prototype.setStatus = function(flags) {
      this.status.carry = (flags & 1 << 0) !== 0;
      this.status.zero = (flags & 1 << 1) !== 0;
      this.status.interrupt = (flags & 1 << 2) !== 0;
      this.status.decimal = (flags & 1 << 3) !== 0;
      this.status["break"] = (flags & 1 << 4) !== 0;
      this.status.overflow = (flags & 1 << 6) !== 0;
      return this.status.negative = (flags & 1 << 7) !== 0;
    };

    CPU.prototype.debug = function(str) {
      return console.log("%d: %sA:%s X:%s Y:%s P: %s S:%s", this.debugCount++, (arguments.length > 0 ? str + ' ' : ''), this.reg.a.val.toString(16), this.reg.x.val.toString(16), this.reg.y.val.toString(16), this.statusRegister().toString(16), this.reg.s.val.toString(16));
    };

    return CPU;

  })();

}).call(this);

(function() {
  window.ab2str = function(buf) {
    return String.fromCharCode.apply(null, new Uint8Array(buf));
  };

  window.str2ab = function(str) {
    var buf, bufView, i, _i, _ref;
    buf = new ArrayBuffer(str.length * 2);
    bufView = new Uint8Array(buf);
    for (i = _i = 0, _ref = str.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      bufView[i] = str.charCodeAt(i);
    }
    return bufView;
  };

  window.byteToAddr = function(l, h) {
    return (h << 8) + l;
  };

  window.toSigned = function(val) {
    if (val >= 0x80) {
      return val - 0x100;
    } else {
      return val;
    }
  };

}).call(this);

(function() {
  var printScreen;

  window.start = function() {
    var romName, xhr;
    romName = 'NEStress.nes';
    if (localStorage[romName]) {
      return run(str2ab(localStorage[romName]));
    } else {
      xhr = new XMLHttpRequest;
      xhr.onload = function() {
        var rom;
        rom = new Uint8Array(this.response);
        localStorage[romName] = ab2str(this.response);
        return run(rom);
      };
      xhr.open('GET', 'img/' + romName, true);
      xhr.responseType = 'arraybuffer';
      return xhr.send();
    }
  };

  window.run = function(data) {
    var canvas, nes, num, _i;
    nes = new NES(data, false);
    for (num = _i = 0; _i < 100000; num = ++_i) {
      nes.step();
    }
    canvas = document.getElementById('screen');
    return printScreen(nes, canvas);
  };

  printScreen = function(nes, canvas) {
    var col, ctx, row, tile, x, y, _i, _results;
    ctx = canvas.getContext('2d');
    _results = [];
    for (row = _i = 0; _i < 30; row = _i += 1) {
      _results.push((function() {
        var _j, _results1;
        _results1 = [];
        for (col = _j = 0; _j < 32; col = _j += 1) {
          tile = nes.ppu.debugNameTable(row, col);
          _results1.push((function() {
            var _k, _results2;
            _results2 = [];
            for (x = _k = 0; _k < 8; x = _k += 1) {
              _results2.push((function() {
                var _l, _results3;
                _results3 = [];
                for (y = _l = 0; _l < 8; y = _l += 1) {
                  ctx.fillStyle = tile[x][y];
                  _results3.push(ctx.fillRect(col * 24 + (y * 3), row * 24 + (x * 3), 3, 3));
                }
                return _results3;
              })());
            }
            return _results2;
          })());
        }
        return _results1;
      })());
    }
    return _results;
  };

}).call(this);

(function() {
  window.NES = (function() {
    function NES(data, printDebug) {
      var index, _i;
      this.printDebug = printDebug != null ? printDebug : false;
      this.rom = new ROM(data);
      this.ram = new Ram(this.rom);
      this.reg = {
        p: new Register(16),
        s: new Register(8),
        x: new Register(8),
        y: new Register(8),
        a: new Register(8)
      };
      this.reg.s.set(0xFD);
      this.reg.p.set((this.rom.get(0xFFFD) << 8) | this.rom.get(0xFFFC));
      this.ram.set(0x0008, 0xF7);
      this.ram.set(0x0009, 0xEF);
      this.ram.set(0x000a, 0xDF);
      this.ram.set(0x000f, 0xBF);
      this.ram.set(0x4017, 0x00);
      this.ram.set(0x4015, 0x00);
      for (index = _i = 0x4000; 0x4000 <= 0x400F ? _i <= 0x400F : _i >= 0x400F; index = 0x4000 <= 0x400F ? ++_i : --_i) {
        this.ram.set(index, 0xFF);
      }
      this.cpu = new CPU(this.ram, this.reg, printDebug);
      this.ppu = new PPU(this.rom, this.ram, this.rom.chrSize === 0, printDebug);
      this.ram.setPPU(this.ppu);
    }

    NES.prototype.step = function() {
      return this.cpu.step();
    };

    NES.prototype.statusRegister = function() {
      return this.cpu.statusRegister();
    };

    NES.prototype.debug = function() {
      this.cpu.debug();
      return this.ppu.debug();
    };

    return NES;

  })();

}).call(this);

(function() {
  window.Ops = {
    0x69: {
      cmd: 'ADC',
      addr: 'imm',
      bytes: 2,
      cycles: 2
    },
    0x65: {
      cmd: 'ADC',
      addr: 'zp',
      bytes: 2,
      cycles: 3
    },
    0x75: {
      cmd: 'ADC',
      addr: 'zpx',
      bytes: 2,
      cycles: 4
    },
    0x6D: {
      cmd: 'ADC',
      addr: 'abs',
      bytes: 3,
      cycles: 4
    },
    0x7D: {
      cmd: 'ADC',
      addr: 'absx',
      bytes: 3,
      cycles: 4
    },
    0x79: {
      cmd: 'ADC',
      addr: 'absy',
      bytes: 3,
      cycles: 4
    },
    0x61: {
      cmd: 'ADC',
      addr: 'indx',
      bytes: 2,
      cycles: 6
    },
    0x71: {
      cmd: 'ADC',
      addr: 'indy',
      bytes: 2,
      cycles: 5
    },
    0x29: {
      cmd: 'AND',
      addr: 'imm',
      bytes: 2,
      cycles: 2
    },
    0x25: {
      cmd: 'AND',
      addr: 'zp',
      bytes: 2,
      cycles: 3
    },
    0x35: {
      cmd: 'AND',
      addr: 'zpx',
      bytes: 2,
      cycles: 4
    },
    0x2D: {
      cmd: 'AND',
      addr: 'abs',
      bytes: 3,
      cycles: 4
    },
    0x3D: {
      cmd: 'AND',
      addr: 'absx',
      bytes: 3,
      cycles: 4
    },
    0x39: {
      cmd: 'AND',
      addr: 'absy',
      bytes: 3,
      cycles: 4
    },
    0x21: {
      cmd: 'AND',
      addr: 'indx',
      bytes: 2,
      cycles: 6
    },
    0x31: {
      cmd: 'AND',
      addr: 'indy',
      bytes: 2,
      cycles: 5
    },
    0x0A: {
      cmd: 'ASL',
      addr: 'acc',
      bytes: 1,
      cycles: 2
    },
    0x06: {
      cmd: 'ASL',
      addr: 'zp',
      bytes: 2,
      cycles: 5
    },
    0x16: {
      cmd: 'ASL',
      addr: 'zpx',
      bytes: 2,
      cycles: 6
    },
    0x0E: {
      cmd: 'ASL',
      addr: 'abs',
      bytes: 3,
      cycles: 6
    },
    0x1E: {
      cmd: 'ASL',
      addr: 'absx',
      bytes: 3,
      cycles: 7
    },
    0x90: {
      cmd: 'BCC',
      addr: 'rel',
      bytes: 2,
      cycles: 2
    },
    0xB0: {
      cmd: 'BCS',
      addr: 'rel',
      bytes: 2,
      cycles: 2
    },
    0xF0: {
      cmd: 'BEQ',
      addr: 'rel',
      bytes: 2,
      cycles: 2
    },
    0x24: {
      cmd: 'BIT',
      addr: 'zp',
      bytes: 2,
      cycles: 3
    },
    0x2C: {
      cmd: 'BIT',
      addr: 'abs',
      bytes: 3,
      cycles: 4
    },
    0x30: {
      cmd: 'BMI',
      addr: 'rel',
      bytes: 2,
      cycles: 2
    },
    0xD0: {
      cmd: 'BNE',
      addr: 'rel',
      bytes: 2,
      cycles: 2
    },
    0x10: {
      cmd: 'BPL',
      addr: 'rel',
      bytes: 2,
      cycles: 2
    },
    0x00: {
      cmd: 'BRK',
      addr: 'imp',
      bytes: 1,
      cycles: 7
    },
    0x50: {
      cmd: 'BVC',
      addr: 'rel',
      bytes: 2,
      cycles: 2
    },
    0x70: {
      cmd: 'BVS',
      addr: 'rel',
      bytes: 2,
      cycles: 2
    },
    0x18: {
      cmd: 'CLC',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0xD8: {
      cmd: 'CLD',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0x58: {
      cmd: 'CLI',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0xB8: {
      cmd: 'CLV',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0xC9: {
      cmd: 'CMP',
      addr: 'imm',
      bytes: 2,
      cycles: 2
    },
    0xC5: {
      cmd: 'CMP',
      addr: 'zp',
      bytes: 2,
      cycles: 3
    },
    0xD5: {
      cmd: 'CMP',
      addr: 'zpx',
      bytes: 2,
      cycles: 4
    },
    0xCD: {
      cmd: 'CMP',
      addr: 'abs',
      bytes: 3,
      cycles: 4
    },
    0xDD: {
      cmd: 'CMP',
      addr: 'absx',
      bytes: 3,
      cycles: 4
    },
    0xD9: {
      cmd: 'CMP',
      addr: 'absy',
      bytes: 3,
      cycles: 4
    },
    0xC1: {
      cmd: 'CMP',
      addr: 'indx',
      bytes: 2,
      cycles: 6
    },
    0xD1: {
      cmd: 'CMP',
      addr: 'indy',
      bytes: 2,
      cycles: 5
    },
    0xE0: {
      cmd: 'CPX',
      addr: 'imm',
      bytes: 2,
      cycles: 2
    },
    0xE4: {
      cmd: 'CPX',
      addr: 'zp',
      bytes: 2,
      cycles: 3
    },
    0xEC: {
      cmd: 'CPX',
      addr: 'abs',
      bytes: 3,
      cycles: 4
    },
    0xC0: {
      cmd: 'CPY',
      addr: 'imm',
      bytes: 2,
      cycles: 2
    },
    0xC4: {
      cmd: 'CPY',
      addr: 'zp',
      bytes: 2,
      cycles: 3
    },
    0xCC: {
      cmd: 'CPY',
      addr: 'abs',
      bytes: 3,
      cycles: 4
    },
    0xC6: {
      cmd: 'DEC',
      addr: 'zp',
      bytes: 2,
      cycles: 5
    },
    0xD6: {
      cmd: 'DEC',
      addr: 'zpx',
      bytes: 2,
      cycles: 6
    },
    0xCE: {
      cmd: 'DEC',
      addr: 'abs',
      bytes: 3,
      cycles: 6
    },
    0xDE: {
      cmd: 'DEC',
      addr: 'absx',
      bytes: 3,
      cycles: 7
    },
    0xCA: {
      cmd: 'DEX',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0x88: {
      cmd: 'DEY',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0x49: {
      cmd: 'EOR',
      addr: 'imm',
      bytes: 2,
      cycles: 2
    },
    0x45: {
      cmd: 'EOR',
      addr: 'zp',
      bytes: 2,
      cycles: 3
    },
    0x55: {
      cmd: 'EOR',
      addr: 'zpx',
      bytes: 2,
      cycles: 4
    },
    0x4D: {
      cmd: 'EOR',
      addr: 'abs',
      bytes: 3,
      cycles: 4
    },
    0x5D: {
      cmd: 'EOR',
      addr: 'absx',
      bytes: 3,
      cycles: 4
    },
    0x59: {
      cmd: 'EOR',
      addr: 'absy',
      bytes: 3,
      cycles: 4
    },
    0x41: {
      cmd: 'EOR',
      addr: 'indx',
      bytes: 2,
      cycles: 6
    },
    0x51: {
      cmd: 'EOR',
      addr: 'indy',
      bytes: 2,
      cycles: 5
    },
    0xE6: {
      cmd: 'INC',
      addr: 'zp',
      bytes: 2,
      cycles: 5
    },
    0xF6: {
      cmd: 'INC',
      addr: 'zpx',
      bytes: 2,
      cycles: 6
    },
    0xEE: {
      cmd: 'INC',
      addr: 'abs',
      bytes: 3,
      cycles: 6
    },
    0xFE: {
      cmd: 'INC',
      addr: 'absx',
      bytes: 3,
      cycles: 7
    },
    0xE8: {
      cmd: 'INX',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0xC8: {
      cmd: 'INY',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0x4C: {
      cmd: 'JMP',
      addr: 'abs',
      bytes: 3,
      cycles: 3
    },
    0x6C: {
      cmd: 'JMP',
      addr: 'ind',
      bytes: 3,
      cycles: 5
    },
    0x20: {
      cmd: 'JSR',
      addr: 'abs',
      bytes: 3,
      cycles: 6
    },
    0xA9: {
      cmd: 'LDA',
      addr: 'imm',
      bytes: 2,
      cycles: 2
    },
    0xA5: {
      cmd: 'LDA',
      addr: 'zp',
      bytes: 2,
      cycles: 3
    },
    0xB5: {
      cmd: 'LDA',
      addr: 'zpx',
      bytes: 2,
      cycles: 4
    },
    0xAD: {
      cmd: 'LDA',
      addr: 'abs',
      bytes: 3,
      cycles: 4
    },
    0xBD: {
      cmd: 'LDA',
      addr: 'absx',
      bytes: 3,
      cycles: 4
    },
    0xB9: {
      cmd: 'LDA',
      addr: 'absy',
      bytes: 3,
      cycles: 4
    },
    0xA1: {
      cmd: 'LDA',
      addr: 'indx',
      bytes: 2,
      cycles: 6
    },
    0xB1: {
      cmd: 'LDA',
      addr: 'indy',
      bytes: 2,
      cycles: 5
    },
    0xA2: {
      cmd: 'LDX',
      addr: 'imm',
      bytes: 2,
      cycles: 2
    },
    0xA6: {
      cmd: 'LDX',
      addr: 'zp',
      bytes: 2,
      cycles: 3
    },
    0xB6: {
      cmd: 'LDX',
      addr: 'zpy',
      bytes: 2,
      cycles: 4
    },
    0xAE: {
      cmd: 'LDX',
      addr: 'abs',
      bytes: 3,
      cycles: 4
    },
    0xBE: {
      cmd: 'LDX',
      addr: 'absy',
      bytes: 3,
      cycles: 4
    },
    0xA0: {
      cmd: 'LDY',
      addr: 'imm',
      bytes: 2,
      cycles: 2
    },
    0xA4: {
      cmd: 'LDY',
      addr: 'zp',
      bytes: 2,
      cycles: 3
    },
    0xB4: {
      cmd: 'LDY',
      addr: 'zpx',
      bytes: 2,
      cycles: 3
    },
    0xAC: {
      cmd: 'LDY',
      addr: 'abs',
      bytes: 3,
      cycles: 4
    },
    0xBC: {
      cmd: 'LDY',
      addr: 'absx',
      bytes: 3,
      cycles: 4
    },
    0x4A: {
      cmd: 'LSR',
      addr: 'acc',
      bytes: 1,
      cycles: 2
    },
    0x46: {
      cmd: 'LSR',
      addr: 'zp',
      bytes: 2,
      cycles: 5
    },
    0x56: {
      cmd: 'LSR',
      addr: 'zpx',
      bytes: 2,
      cycles: 6
    },
    0x4E: {
      cmd: 'LSR',
      addr: 'abs',
      bytes: 3,
      cycles: 6
    },
    0x5E: {
      cmd: 'LSR',
      addr: 'absx',
      bytes: 3,
      cycles: 7
    },
    0xEA: {
      cmd: 'NOP',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0x09: {
      cmd: 'ORA',
      addr: 'imm',
      bytes: 2,
      cycles: 2
    },
    0x05: {
      cmd: 'ORA',
      addr: 'zp',
      bytes: 2,
      cycles: 3
    },
    0x15: {
      cmd: 'ORA',
      addr: 'zpx',
      bytes: 2,
      cycles: 4
    },
    0x0D: {
      cmd: 'ORA',
      addr: 'abs',
      bytes: 3,
      cycles: 4
    },
    0x1D: {
      cmd: 'ORA',
      addr: 'absx',
      bytes: 3,
      cycles: 4
    },
    0x19: {
      cmd: 'ORA',
      addr: 'absy',
      bytes: 3,
      cycles: 4
    },
    0x01: {
      cmd: 'ORA',
      addr: 'indx',
      bytes: 2,
      cycles: 6
    },
    0x11: {
      cmd: 'ORA',
      addr: 'indy',
      bytes: 2,
      cycles: 5
    },
    0x48: {
      cmd: 'PHA',
      addr: 'imp',
      bytes: 1,
      cycles: 3
    },
    0x08: {
      cmd: 'PHP',
      addr: 'imp',
      bytes: 1,
      cycles: 3
    },
    0x68: {
      cmd: 'PLA',
      addr: 'imp',
      bytes: 1,
      cycles: 4
    },
    0x28: {
      cmd: 'PLP',
      addr: 'imp',
      bytes: 1,
      cycles: 4
    },
    0x2A: {
      cmd: 'ROL',
      addr: 'acc',
      bytes: 1,
      cycles: 2
    },
    0x26: {
      cmd: 'ROL',
      addr: 'zp',
      bytes: 2,
      cycles: 5
    },
    0x36: {
      cmd: 'ROL',
      addr: 'zpx',
      bytes: 2,
      cycles: 6
    },
    0x2E: {
      cmd: 'ROL',
      addr: 'abs',
      bytes: 3,
      cycles: 6
    },
    0x3E: {
      cmd: 'ROL',
      addr: 'absx',
      bytes: 3,
      cycles: 7
    },
    0x6A: {
      cmd: 'ROR',
      addr: 'acc',
      bytes: 1,
      cycles: 2
    },
    0x66: {
      cmd: 'ROR',
      addr: 'zp',
      bytes: 2,
      cycles: 5
    },
    0x76: {
      cmd: 'ROR',
      addr: 'zpx',
      bytes: 2,
      cycles: 6
    },
    0x6E: {
      cmd: 'ROR',
      addr: 'abs',
      bytes: 3,
      cycles: 6
    },
    0x7E: {
      cmd: 'ROR',
      addr: 'absx',
      bytes: 3,
      cycles: 7
    },
    0x40: {
      cmd: 'RTI',
      addr: 'imp',
      bytes: 1,
      cycles: 6
    },
    0x60: {
      cmd: 'RTS',
      addr: 'imp',
      bytes: 1,
      cycles: 6
    },
    0xE9: {
      cmd: 'SBC',
      addr: 'imm',
      bytes: 2,
      cycles: 2
    },
    0xE5: {
      cmd: 'SBC',
      addr: 'zp',
      bytes: 2,
      cycles: 3
    },
    0xF5: {
      cmd: 'SBC',
      addr: 'zpx',
      bytes: 2,
      cycles: 4
    },
    0xED: {
      cmd: 'SBC',
      addr: 'abs',
      bytes: 3,
      cycles: 4
    },
    0xFD: {
      cmd: 'SBC',
      addr: 'absx',
      bytes: 3,
      cycles: 4
    },
    0xF9: {
      cmd: 'SBC',
      addr: 'absy',
      bytes: 3,
      cycles: 4
    },
    0xE1: {
      cmd: 'SBC',
      addr: 'indx',
      bytes: 2,
      cycles: 6
    },
    0xF1: {
      cmd: 'SBC',
      addr: 'indy',
      bytes: 2,
      cycles: 5
    },
    0x38: {
      cmd: 'SEC',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0xF8: {
      cmd: 'SED',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0x78: {
      cmd: 'SEI',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0x85: {
      cmd: 'STA',
      addr: 'zp',
      bytes: 2,
      cycles: 3
    },
    0x95: {
      cmd: 'STA',
      addr: 'zpx',
      bytes: 2,
      cycles: 4
    },
    0x8D: {
      cmd: 'STA',
      addr: 'abs',
      bytes: 3,
      cycles: 4
    },
    0x9D: {
      cmd: 'STA',
      addr: 'absx',
      bytes: 3,
      cycles: 5
    },
    0x99: {
      cmd: 'STA',
      addr: 'absy',
      bytes: 3,
      cycles: 5
    },
    0x81: {
      cmd: 'STA',
      addr: 'indx',
      bytes: 2,
      cycles: 6
    },
    0x91: {
      cmd: 'STA',
      addr: 'indy',
      bytes: 2,
      cycles: 6
    },
    0x86: {
      cmd: 'STX',
      addr: 'zp',
      bytes: 2,
      cycles: 3
    },
    0x96: {
      cmd: 'STX',
      addr: 'zpy',
      bytes: 2,
      cycles: 4
    },
    0x8E: {
      cmd: 'STX',
      addr: 'abs',
      bytes: 3,
      cycles: 4
    },
    0x84: {
      cmd: 'STY',
      addr: 'zp',
      bytes: 2,
      cycles: 3
    },
    0x94: {
      cmd: 'STY',
      addr: 'zpx',
      bytes: 2,
      cycles: 4
    },
    0x8C: {
      cmd: 'STY',
      addr: 'abs',
      bytes: 3,
      cycles: 4
    },
    0xAA: {
      cmd: 'TAX',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0xA8: {
      cmd: 'TAY',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0xBA: {
      cmd: 'TSX',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0x8A: {
      cmd: 'TXA',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0x9A: {
      cmd: 'TXS',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0x98: {
      cmd: 'TYA',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0xC7: {
      cmd: 'DCP',
      addr: 'zp',
      bytes: 2,
      cycles: 5
    },
    0xD7: {
      cmd: 'DCP',
      addr: 'zpx',
      bytes: 2,
      cycles: 6
    },
    0xCF: {
      cmd: 'DCP',
      addr: 'abs',
      bytes: 3,
      cycles: 6
    },
    0xDF: {
      cmd: 'DCP',
      addr: 'absx',
      bytes: 3,
      cycles: 7
    },
    0xDB: {
      cmd: 'DCP',
      addr: 'absy',
      bytes: 3,
      cycles: 7
    },
    0xC3: {
      cmd: 'DCP',
      addr: 'indx',
      bytes: 2,
      cycles: 8
    },
    0xD3: {
      cmd: 'DCP',
      addr: 'indy',
      bytes: 2,
      cycles: 8
    },
    0xE7: {
      cmd: 'ISC',
      addr: 'zp',
      bytes: 2,
      cycles: 5
    },
    0xF7: {
      cmd: 'ISC',
      addr: 'zpx',
      bytes: 2,
      cycles: 6
    },
    0xEF: {
      cmd: 'ISC',
      addr: 'abs',
      bytes: 3,
      cycles: 6
    },
    0xFF: {
      cmd: 'ISC',
      addr: 'absx',
      bytes: 3,
      cycles: 7
    },
    0xFB: {
      cmd: 'ISC',
      addr: 'absy',
      bytes: 3,
      cycles: 7
    },
    0xE3: {
      cmd: 'ISC',
      addr: 'indx',
      bytes: 2,
      cycles: 8
    },
    0xF3: {
      cmd: 'ISC',
      addr: 'indy',
      bytes: 2,
      cycles: 8
    },
    0xA7: {
      cmd: 'LAX',
      addr: 'zp',
      bytes: 2,
      cycles: 3
    },
    0xB7: {
      cmd: 'LAX',
      addr: 'zpy',
      bytes: 2,
      cycles: 4
    },
    0xAF: {
      cmd: 'LAX',
      addr: 'abs',
      bytes: 3,
      cycles: 4
    },
    0xBF: {
      cmd: 'LAX',
      addr: 'absy',
      bytes: 3,
      cycles: 4
    },
    0xA3: {
      cmd: 'LAX',
      addr: 'indx',
      bytes: 2,
      cycles: 6
    },
    0xB3: {
      cmd: 'LAX',
      addr: 'indy',
      bytes: 2,
      cycles: 5
    },
    0x1A: {
      cmd: 'NOP',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0x3A: {
      cmd: 'NOP',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0x5A: {
      cmd: 'NOP',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0x7A: {
      cmd: 'NOP',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0xDA: {
      cmd: 'NOP',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0xFA: {
      cmd: 'NOP',
      addr: 'imp',
      bytes: 1,
      cycles: 2
    },
    0x04: {
      cmd: 'NOP',
      addr: 'zp',
      bytes: 2,
      cycles: 3
    },
    0x44: {
      cmd: 'NOP',
      addr: 'zp',
      bytes: 2,
      cycles: 3
    },
    0x64: {
      cmd: 'NOP',
      addr: 'zp',
      bytes: 2,
      cycles: 3
    },
    0x14: {
      cmd: 'NOP',
      addr: 'zpx',
      bytes: 2,
      cycles: 4
    },
    0x34: {
      cmd: 'NOP',
      addr: 'zpx',
      bytes: 2,
      cycles: 4
    },
    0x54: {
      cmd: 'NOP',
      addr: 'zpx',
      bytes: 2,
      cycles: 4
    },
    0x74: {
      cmd: 'NOP',
      addr: 'zpx',
      bytes: 2,
      cycles: 4
    },
    0xD4: {
      cmd: 'NOP',
      addr: 'zpx',
      bytes: 2,
      cycles: 4
    },
    0xF4: {
      cmd: 'NOP',
      addr: 'zpx',
      bytes: 2,
      cycles: 4
    },
    0x80: {
      cmd: 'NOP',
      addr: 'imm',
      bytes: 2,
      cycles: 2
    },
    0x82: {
      cmd: 'NOP',
      addr: 'imm',
      bytes: 2,
      cycles: 2
    },
    0x89: {
      cmd: 'NOP',
      addr: 'imm',
      bytes: 2,
      cycles: 2
    },
    0xC2: {
      cmd: 'NOP',
      addr: 'imm',
      bytes: 2,
      cycles: 2
    },
    0xE2: {
      cmd: 'NOP',
      addr: 'imm',
      bytes: 2,
      cycles: 2
    },
    0x0C: {
      cmd: 'NOP',
      addr: 'abs',
      bytes: 3,
      cycles: 4
    },
    0x1C: {
      cmd: 'NOP',
      addr: 'absx',
      bytes: 3,
      cycles: 4
    },
    0x3C: {
      cmd: 'NOP',
      addr: 'absx',
      bytes: 3,
      cycles: 4
    },
    0x5C: {
      cmd: 'NOP',
      addr: 'absx',
      bytes: 3,
      cycles: 4
    },
    0x7C: {
      cmd: 'NOP',
      addr: 'absx',
      bytes: 3,
      cycles: 4
    },
    0xDC: {
      cmd: 'NOP',
      addr: 'absx',
      bytes: 3,
      cycles: 4
    },
    0xFC: {
      cmd: 'NOP',
      addr: 'absx',
      bytes: 3,
      cycles: 4
    },
    0x27: {
      cmd: 'RLA',
      addr: 'zp',
      bytes: 2,
      cycles: 5
    },
    0x37: {
      cmd: 'RLA',
      addr: 'zpx',
      bytes: 2,
      cycles: 6
    },
    0x2F: {
      cmd: 'RLA',
      addr: 'abs',
      bytes: 3,
      cycles: 6
    },
    0x3F: {
      cmd: 'RLA',
      addr: 'absx',
      bytes: 3,
      cycles: 7
    },
    0x3B: {
      cmd: 'RLA',
      addr: 'absy',
      bytes: 3,
      cycles: 7
    },
    0x23: {
      cmd: 'RLA',
      addr: 'indx',
      bytes: 2,
      cycles: 8
    },
    0x33: {
      cmd: 'RLA',
      addr: 'indy',
      bytes: 2,
      cycles: 8
    },
    0x67: {
      cmd: 'RRA',
      addr: 'zp',
      bytes: 2,
      cycles: 5
    },
    0x77: {
      cmd: 'RRA',
      addr: 'zpx',
      bytes: 2,
      cycles: 6
    },
    0x6F: {
      cmd: 'RRA',
      addr: 'abs',
      bytes: 3,
      cycles: 6
    },
    0x7F: {
      cmd: 'RRA',
      addr: 'absx',
      bytes: 3,
      cycles: 7
    },
    0x7B: {
      cmd: 'RRA',
      addr: 'absy',
      bytes: 3,
      cycles: 7
    },
    0x63: {
      cmd: 'RRA',
      addr: 'indx',
      bytes: 2,
      cycles: 8
    },
    0x73: {
      cmd: 'RRA',
      addr: 'indy',
      bytes: 2,
      cycles: 8
    },
    0x87: {
      cmd: 'SAX',
      addr: 'zp',
      bytes: 2,
      cycles: 3
    },
    0x97: {
      cmd: 'SAX',
      addr: 'zpy',
      bytes: 2,
      cycles: 4
    },
    0x83: {
      cmd: 'SAX',
      addr: 'indx',
      bytes: 2,
      cycles: 6
    },
    0x8F: {
      cmd: 'SAX',
      addr: 'abs',
      bytes: 3,
      cycles: 4
    },
    0xEB: {
      cmd: 'SBC',
      addr: 'imm',
      bytes: 2,
      cycles: 2
    },
    0x07: {
      cmd: 'SLO',
      addr: 'zp',
      bytes: 2,
      cycles: 5
    },
    0x17: {
      cmd: 'SLO',
      addr: 'zpx',
      bytes: 2,
      cycles: 6
    },
    0x0F: {
      cmd: 'SLO',
      addr: 'abs',
      bytes: 3,
      cycles: 6
    },
    0x1F: {
      cmd: 'SLO',
      addr: 'absx',
      bytes: 3,
      cycles: 7
    },
    0x1B: {
      cmd: 'SLO',
      addr: 'absy',
      bytes: 3,
      cycles: 7
    },
    0x03: {
      cmd: 'SLO',
      addr: 'indx',
      bytes: 2,
      cycles: 8
    },
    0x13: {
      cmd: 'SLO',
      addr: 'indy',
      bytes: 2,
      cycles: 8
    },
    0x47: {
      cmd: 'SRE',
      addr: 'zp',
      bytes: 2,
      cycles: 5
    },
    0x57: {
      cmd: 'SRE',
      addr: 'zpx',
      bytes: 2,
      cycles: 6
    },
    0x4F: {
      cmd: 'SRE',
      addr: 'abs',
      bytes: 3,
      cycles: 6
    },
    0x5F: {
      cmd: 'SRE',
      addr: 'absx',
      bytes: 3,
      cycles: 7
    },
    0x5B: {
      cmd: 'SRE',
      addr: 'absy',
      bytes: 3,
      cycles: 7
    },
    0x43: {
      cmd: 'SRE',
      addr: 'indx',
      bytes: 2,
      cycles: 8
    },
    0x53: {
      cmd: 'SRE',
      addr: 'indy',
      bytes: 2,
      cycles: 8
    }
  };

}).call(this);

(function() {
  window.PPU = (function() {
    function PPU(rom, ram, hasChrRam, printDebug) {
      var num;
      this.rom = rom;
      this.ram = ram;
      this.hasChrRam = hasChrRam != null ? hasChrRam : false;
      this.printDebug = printDebug != null ? printDebug : false;
      this.reg = (function() {
        var _i, _results;
        _results = [];
        for (num = _i = 0; _i < 8; num = ++_i) {
          _results.push(0x00);
        }
        return _results;
      })();
      this.vram = (function() {
        var _i, _results;
        _results = [];
        for (num = _i = 0; 0 <= 0x4000 ? _i < 0x4000 : _i > 0x4000; num = 0 <= 0x4000 ? ++_i : --_i) {
          _results.push(0x00);
        }
        return _results;
      })();
      this.oam = (function() {
        var _i, _results;
        _results = [];
        for (num = _i = 0; 0 <= 0x100 ? _i < 0x100 : _i > 0x100; num = 0 <= 0x100 ? ++_i : --_i) {
          _results.push(0x00);
        }
        return _results;
      })();
      this.reg[2] = 0x80;
      this.address = 0;
      this.oamAddr = 0;
      this.scroll;
      this.readBuffer = 0;
      this.firstAddr = true;
      this.firstScroll = true;
      this.colors = ['#7C7C7C', '#0000FC', '#0000BC', '#4428BC', '#940084', '#A80020', '#A81000', '#881400', '#503000', '#007800', '#006800', '#005800', '#004058', '#000000', '#000000', '#000000', '#BCBCBC', '#0078F8', '#0058F8', '#6844FC', '#D800CC', '#E40058', '#F83800', '#E45C10', '#AC7C00', '#00B800', '#00A800', '#00A844', '#008888', '#000000', '#000000', '#000000', '#F8F8F8', '#3CBCFC', '#6888FC', '#9878F8', '#F878F8', '#F85898', '#F87858', '#FCA044', '#F8B800', '#B8F818', '#58D854', '#58F898', '#00E8D8', '#787878', '#000000', '#000000', '#FCFCFC', '#A4E4FC', '#B8B8F8', '#D8B8F8', '#F8B8F8', '#F8A4C0', '#F0D0B0', '#FCE0A8', '#F8D878', '#D8F878', '#B8F8B8', '#B8F8D8', '#00FCFC', '#F8D8F8', '#000000', '#000000'];
    }

    PPU.prototype.debug = function() {
      return console.log(this.reg, this.hasChrRam, this.rom.chr, this.vram);
    };

    PPU.prototype.getVRam = function(addr) {
      if (!this.hasChrRam && addr < 0x2000) {
        return this.rom.getVRom(addr);
      } else if (addr >= 0x3000 && addr < 0x3F00) {
        return this.vram[addr - 0x1000];
      } else if (addr >= 0x3F00 && addr < 0x4000) {
        addr = addr & 0x1F;
        if (addr >= 0x10 && (addr & 0x3) === 0) {
          addr -= 0x10;
        }
        return this.vram[0x3F00 + addr];
      } else {
        return this.vram[addr];
      }
    };

    PPU.prototype.setVRam = function(addr, value) {
      if (addr >= 0x3000 && addr < 0x3F00) {
        return this.vram[addr - 0x1000] = value;
      } else if (addr >= 0x3F00 && addr < 0x4000) {
        addr = addr & 0x1F;
        if (addr >= 0x10 && (addr & 0x3) === 0) {
          addr -= 0x10;
        }
        return this.vram[0x3F00 + addr] = value;
      } else {
        return this.vram[addr] = value;
      }
    };

    PPU.prototype.getReg = function(addr) {
      var ret;
      switch (addr) {
        case 2:
          this.firstAddr = this.firstScroll = true;
          return 0x80;
        case 4:
          return this.oam[this.oamAddr];
        case 7:
          if (this.address >= 0x3F00) {
            ret = this.getVRam(this.address);
            this.readBuffer = this.getVRam(this.address - 0x1000);
            this.address = this.address + 1;
            return ret;
          } else {
            ret = this.readBuffer;
            this.readBuffer = this.getVRam(this.address);
            this.address = this.address + 1;
            return ret;
          }
      }
    };

    PPU.prototype.setReg = function(addr, value) {
      this.reg[addr] = value;
      switch (addr) {
        case 0:
          return console.log("set controller", value.toString(2));
        case 1:
          return console.log("set mask", value.toString(2));
        case 3:
          return this.oamAddr = value;
        case 4:
          this.oam[this.oamAddr] = value;
          return this.oamAddr = (this.oamAddr + 1) & 0xFF;
        case 5:
          if (this.firstScroll) {
            this.scroll = (value << 8) | (this.scroll & 0x00FF);
          } else {
            this.scroll = value | (this.scroll & 0xFF00);
          }
          return this.firstScroll = !this.firstScroll;
        case 6:
          if (this.firstAddr) {
            this.address = (value << 8) | (this.address & 0xFF);
          } else {
            this.address = value | (this.address & 0xFF00);
          }
          return this.firstAddr = !this.firstAddr;
        case 7:
          this.setVRam(this.address, value);
          return this.address = this.address + 1;
      }
    };

    PPU.prototype.oamDma = function(value) {
      var i, _i, _results;
      _results = [];
      for (i = _i = 0; 0 <= 0x100 ? _i < 0x100 : _i > 0x100; i = 0 <= 0x100 ? ++_i : --_i) {
        _results.push(this.oam[i] = this.ram.get(value | i));
      }
      return _results;
    };

    PPU.prototype.debugNameTable = function(row, col) {
      var attribute, attributeValue, nameTable, palette, tile;
      nameTable = this.getVRam(0x2000 + (row * 32) + col);
      attributeValue = this.getVRam(0x23C0 + (Math.floor(row / 2) * 8) + Math.floor(col / 2));
      attribute = null;
      if (row % 2 === 1 && col % 2 === 1) {
        attribute = attributeValue & 0x3;
      } else if (row % 2 === 1 && col % 2 === 0) {
        attribute = (attributeValue >> 2) & 0x3;
      } else if (row % 2 === 0 && col % 2 === 1) {
        attribute = (attributeValue >> 4) & 0x3;
      } else if (row % 2 === 0 && col % 2 === 0) {
        attribute = (attributeValue >> 6) & 0x3;
      }
      palette = this.getBackgroundPalette(attribute);
      tile = this.getTile(nameTable, palette);
      return tile;
    };

    PPU.prototype.getTile = function(tileNumber, palette) {
      var b, h, i, l, offset, tile, value, _i, _j;
      offset = (this.reg[0] & 0x10) !== 0 ? 0x1000 : 0;
      tile = [];
      for (i = _i = 0; _i < 8; i = _i += 1) {
        h = this.getVRam(offset + (tileNumber * 16) + i);
        l = this.getVRam(offset + (tileNumber * 16) + i + 8);
        tile[i] = [];
        for (b = _j = 0; _j < 8; b = _j += 1) {
          value = (h & (1 << b)) === 0 ? 0 : 2;
          value += (l & (1 << b)) === 0 ? 0 : 1;
          tile[i][7 - b] = this.colors[palette[value]];
        }
      }
      return tile;
    };

    PPU.prototype.getBackgroundPalette = function(number) {
      var colors, i, _i;
      colors = [];
      colors[0] = this.getVRam(0x3F00);
      for (i = _i = 1; _i <= 3; i = ++_i) {
        colors[i] = this.getVRam(0x3F00 + (3 * number) + i);
      }
      return colors;
    };

    return PPU;

  })();

}).call(this);

(function() {
  window.Ram = (function() {
    function Ram(rom) {
      var num;
      this.rom = rom;
      this.ram = (function() {
        var _i, _results;
        _results = [];
        for (num = _i = 0; 0 <= 0x800 ? _i < 0x800 : _i > 0x800; num = 0 <= 0x800 ? ++_i : --_i) {
          _results.push(0xFF);
        }
        return _results;
      })();
      this.apu = (function() {
        var _i, _results;
        _results = [];
        for (num = _i = 0; 0 <= 0x20 ? _i < 0x20 : _i > 0x20; num = 0 <= 0x20 ? ++_i : --_i) {
          _results.push(0x00);
        }
        return _results;
      })();
      this.ppu = null;
    }

    Ram.prototype.setPPU = function(ppu) {
      this.ppu = ppu;
    };

    Ram.prototype.get = function(index) {
      if (index >= 0 && index < 0x2000) {
        return this.ram[index % 0x800];
      }
      if (index >= 0x2000 && index < 0x4000) {
        return this.ppu.getReg(index % 8);
      }
      if (index >= 0x4000 && index < 0x4020) {
        return this.apu[index % 0x20];
      }
      if (index >= 0x8000 && index < 0x10000) {
        return this.rom.get(index);
      }
      throw "Invalid index " + index;
    };

    Ram.prototype.set = function(index, value) {
      if (value > 0xFF || value < 0) {
        throw "Invalid value " + value;
      }
      if (index >= 0 && index < 0x2000) {
        return this.ram[index % 0x800] = value;
      } else if (index >= 0x2000 && index < 0x4000) {
        return this.ppu.setReg(index % 8, value);
      } else if (index === 0x4014) {
        return this.ppu.oamDma(value);
      } else if (index >= 0x4000 && index < 0x4020) {
        return this.apu[index % 0x20] = value;
      } else {
        throw "Invalid index 0x" + index.toString(16);
      }
    };

    return Ram;

  })();

}).call(this);

(function() {
  window.Register = (function() {
    function Register(bits) {
      this.bits = bits;
      this.val = 0;
      this.zero = true;
      this.carry = this.overflow = this.neg = false;
      this.max = Math.pow(2, this.bits);
    }

    Register.prototype.add = function(value, carry) {
      var prev;
      if (carry == null) {
        carry = false;
      }
      if (Math.abs(value) >= this.max) {
        throw "Invalid value: " + value;
      }
      prev = this.val;
      this.val += value;
      if (carry) {
        this.val += 1;
      }
      this.overflow = (prev < this.max / 2 && value < this.max / 2 && this.val >= this.max / 2) || (prev >= this.max / 2 && value >= this.max / 2 && this.val < this.max / 2);
      this.carry = this.val >= this.max;
      this.val = (this.val + this.max) % this.max;
      this.zero = this.val === 0;
      return this.neg = this.val >= this.max / 2;
    };

    Register.prototype.sub = function(value, carry) {
      var prev;
      if (carry == null) {
        carry = false;
      }
      if (Math.abs(value) >= this.max) {
        throw "Invalid value: " + value;
      }
      prev = this.val;
      this.val -= value;
      if (carry) {
        this.val -= 1;
      }
      this.overflow = (prev < this.max / 2 && value >= this.max / 2 && this.val >= this.max / 2) || (prev >= this.max / 2 && value < this.max / 2 && this.val < this.max / 2);
      this.carry = this.val >= this.max;
      this.val = (this.val + this.max) % this.max;
      this.zero = this.val === 0;
      return this.neg = this.val >= this.max / 2;
    };

    Register.prototype.shiftRight = function(carry) {
      if (carry == null) {
        carry = false;
      }
      this.carry = (this.val & 0x1) !== 0;
      this.val = this.val >> 1;
      if (carry) {
        this.val |= 0x80;
      }
      this.zero = this.val === 0;
      return this.neg = this.val >= this.max / 2;
    };

    Register.prototype.shiftLeft = function(carry) {
      if (carry == null) {
        carry = false;
      }
      this.carry = (this.val & 0x80) !== 0;
      this.val = (this.val << 1) & 0xFF;
      if (carry) {
        this.val |= 0x01;
      }
      this.zero = this.val === 0;
      return this.neg = this.val >= this.max / 2;
    };

    Register.prototype.set = function(value) {
      if (Math.abs(value) >= this.max) {
        throw "Invalid value: " + value;
      }
      this.val = (value + this.max) % this.max;
      this.zero = this.val === 0;
      return this.neg = this.val >= this.max / 2;
    };

    return Register;

  })();

}).call(this);

(function() {
  window.ROM = (function() {
    function ROM(data) {
      this.data = data;
      if (this.data[0] !== 0x4e || this.data[1] !== 0x45 || this.data[2] !== 0x53 || this.data[3] !== 0x1A) {
        throw "Invalid file";
      }
      this.prgSize = data[4];
      this.chrSize = data[5];
      this.flag6 = data[6];
      this.flag7 = data[7];
      this.ramSIze = data[8];
      this.flag9 = data[9];
      this.flag10 = data[10];
      this.mapper = (this.flag7 & 0xF0) | (this.flag6 >> 4);
      this.prg = this.data.subarray(0x10, (0x4000 * this.prgSize) + 0x10);
      this.chr = this.data.subarray((0x4000 * this.prgSize) + 0x10, (0x4000 * this.prgSize) + 0x10 + (0x2000 * this.chrSize));
    }

    ROM.prototype.get = function(addr) {
      if (addr >= 0x8000 && addr < 0x10000) {
        return this.prg[addr % (0x4000 * this.prgSize)];
      }
    };

    ROM.prototype.getVRom = function(addr) {
      if (addr >= 0x0 && addr < 0x2000) {
        return this.chr[addr];
      }
    };

    return ROM;

  })();

}).call(this);
