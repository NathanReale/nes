describe "Register", ->
	Given -> @reg = new Register(8)
	Then -> @reg.val == 0
	And -> @reg.zero == true
	And -> @reg.carry == false
	And -> @reg.overflow == false
	And -> @reg.neg == false

	describe "Add", ->
		describe "Add 1", ->
			When -> @reg.add(1)
			Then -> @reg.val == 1
			And -> @reg.zero == false
			And -> @reg.carry == false
			And -> @reg.overflow == false
			And -> @reg.neg == false

		describe "Add with overflow", ->
			When -> @reg.add(0x70)
			When -> @reg.add(0x70)
			Then -> @reg.val == 0xE0
			And -> @reg.zero == false
			And -> @reg.carry == false
			And -> @reg.overflow == true
			And -> @reg.neg == true

		describe "Add with carry", ->
			When -> @reg.add(127)
			When -> @reg.add(129)
			Then -> @reg.val == 0
			And -> @reg.zero == true
			And -> @reg.carry == true
			And -> @reg.overflow == false
			And -> @reg.neg == false

		describe "Add 127", ->
			When -> @reg.add(127)
			Then -> @reg.val == 127
			And -> @reg.zero == false
			And -> @reg.carry == false
			And -> @reg.overflow == false
			And -> @reg.neg == false

		describe "Add 128", ->
			When -> @reg.add(128)
			Then -> @reg.val == 128
			And -> @reg.zero == false
			And -> @reg.carry == false
			And -> @reg.overflow == false
			And -> @reg.neg == true

		describe "Invalid value", ->
			Then -> expect(-> @reg.add(256)).toThrow()

	describe "Set", ->
		When -> @reg.set(200)
		Then -> @reg.val == 200
		And -> @reg.zero == false
		And -> @reg.neg == true



