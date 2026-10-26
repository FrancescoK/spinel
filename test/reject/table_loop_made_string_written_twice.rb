# A String the loop computes is one object in CRuby, held by both
# constants (`A1.equal?(B1)`). Each place a node writes is a new object, so
# the loop stays as written, which Spinel refuses.
module K
  NAMES = { 1 => "x", 2 => "y" }
  NAMES.each { |code, v|
    s = "#{v}!"
    const_set("A#{code}", s)
    const_set("B#{code}", s)
  }
end
p K::A1, K::A1.equal?(K::B1)
