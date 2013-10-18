describe "NES", ->
  When -> @nes = NES()
  Then -> expect(@nes).toEqual("test NES")