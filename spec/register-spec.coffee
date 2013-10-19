describe "Register", ->
	Given -> @reg = new Register(8)
	Then -> @reg.val == 0
	And -> @reg.zero == true
	And -> @reg.carry == false
	And -> @reg.overflow == false
	And -> @reg.neg == false

	describe "Add 1", ->
		When -> @reg.add(1)
		Then -> @reg.val == 1
		And -> @reg.zero == false
		And -> @reg.carry == false
		And -> @reg.overflow == false
		And -> @reg.neg == false

	describe "Add with overflow", ->
		When -> @reg.add(200)
		Then -> @reg.val == 200
		And -> @reg.zero == false
		And -> @reg.carry == false
		And -> @reg.overflow == true
		And -> @reg.neg == true

	describe "Add with carry and overflow", ->
		When -> @reg.add(128)
		When -> @reg.add(128)
		Then -> @reg.val == 0
		And -> @reg.zero == true
		And -> @reg.carry == true
		And -> @reg.overflow == true
		And -> @reg.neg == false

	describe "Subtract without overflow", ->
		When -> @reg.add(-50)
		Then -> @reg.val == (256-50)
		And -> @reg.zero == false
		And -> @reg.carry == false
		And -> @reg.overflow == false
		And -> @reg.neg == true

	describe "Subtract with overflow", ->
		When -> @reg.add(-200)
		Then -> @reg.val == (256-200)
		And -> @reg.zero == false
		And -> @reg.carry == false
		And -> @reg.overflow == true
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
		And -> @reg.overflow == true
		And -> @reg.neg == true

	describe "Invalid value", ->
		Then -> expect(-> @reg.add(256)).toThrow()



