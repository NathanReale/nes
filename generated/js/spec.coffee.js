(function() {
  describe("NES", function() {
    return describe("Initialization", function() {
      Given(function() {
        return this.nes = new NES(null);
      });
      Then(function() {
        return this.nes.reg.p.val === 0x34;
      });
      Then(function() {
        return this.nes.reg.s.val === 0xFD;
      });
      Then(function() {
        return this.nes.reg.a.val === 0;
      });
      Then(function() {
        return this.nes.reg.x.val === 0;
      });
      Then(function() {
        return this.nes.reg.y.val === 0;
      });
      Then(function() {
        return this.nes.ram.get(0x0000) === 0xFF;
      });
      Then(function() {
        return this.nes.ram.get(0x0008) === 0xF7;
      });
      Then(function() {
        return this.nes.ram.get(0x0009) === 0xEF;
      });
      Then(function() {
        return this.nes.ram.get(0x000a) === 0xDF;
      });
      return Then(function() {
        return this.nes.ram.get(0x000f) === 0xBF;
      });
    });
  });

}).call(this);

(function() {
  describe("Register", function() {
    Given(function() {
      return this.reg = new Register(8);
    });
    Then(function() {
      return this.reg.val === 0;
    });
    And(function() {
      return this.reg.zero === true;
    });
    And(function() {
      return this.reg.carry === false;
    });
    And(function() {
      return this.reg.overflow === false;
    });
    And(function() {
      return this.reg.neg === false;
    });
    describe("Add", function() {
      describe("Add 1", function() {
        When(function() {
          return this.reg.add(1);
        });
        Then(function() {
          return this.reg.val === 1;
        });
        And(function() {
          return this.reg.zero === false;
        });
        And(function() {
          return this.reg.carry === false;
        });
        And(function() {
          return this.reg.overflow === false;
        });
        return And(function() {
          return this.reg.neg === false;
        });
      });
      describe("Add with overflow", function() {
        When(function() {
          return this.reg.add(0x70);
        });
        When(function() {
          return this.reg.add(0x70);
        });
        Then(function() {
          return this.reg.val === 0xE0;
        });
        And(function() {
          return this.reg.zero === false;
        });
        And(function() {
          return this.reg.carry === false;
        });
        And(function() {
          return this.reg.overflow === true;
        });
        return And(function() {
          return this.reg.neg === true;
        });
      });
      describe("Add with carry", function() {
        When(function() {
          return this.reg.add(127);
        });
        When(function() {
          return this.reg.add(129);
        });
        Then(function() {
          return this.reg.val === 0;
        });
        And(function() {
          return this.reg.zero === true;
        });
        And(function() {
          return this.reg.carry === true;
        });
        And(function() {
          return this.reg.overflow === false;
        });
        return And(function() {
          return this.reg.neg === false;
        });
      });
      describe("Add 127", function() {
        When(function() {
          return this.reg.add(127);
        });
        Then(function() {
          return this.reg.val === 127;
        });
        And(function() {
          return this.reg.zero === false;
        });
        And(function() {
          return this.reg.carry === false;
        });
        And(function() {
          return this.reg.overflow === false;
        });
        return And(function() {
          return this.reg.neg === false;
        });
      });
      describe("Add 128", function() {
        When(function() {
          return this.reg.add(128);
        });
        Then(function() {
          return this.reg.val === 128;
        });
        And(function() {
          return this.reg.zero === false;
        });
        And(function() {
          return this.reg.carry === false;
        });
        And(function() {
          return this.reg.overflow === false;
        });
        return And(function() {
          return this.reg.neg === true;
        });
      });
      return describe("Invalid value", function() {
        return Then(function() {
          return expect(function() {
            return this.reg.add(256);
          }).toThrow();
        });
      });
    });
    return describe("Set", function() {
      When(function() {
        return this.reg.set(200);
      });
      Then(function() {
        return this.reg.val === 200;
      });
      And(function() {
        return this.reg.zero === false;
      });
      return And(function() {
        return this.reg.neg === true;
      });
    });
  });

}).call(this);
