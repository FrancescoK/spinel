# An Array the loop makes is one object in CRuby, held by both constants
# (`A1.equal?(B1)`). Each place a node writes is a new Array, so the loop
# stays as written, which Spinel refuses.
module K
  NAMES = { 1 => "x", 2 => "y" }
  NAMES.each { |code, v|
    a = [code, code]
    const_set("A#{code}", a)
    const_set("B#{code}", a)
  }
end
p K::A1, K::A1.equal?(K::B1)
