# The Strings a table loop writes keep CRuby's objects: one the loop
# computes (interpolation, an Array of them) is a new unfrozen String; a
# literal, adjacent literals and a table String are the frozen literal of
# their bytes, which `to_s` answers itself.
module K
  NAMES = { 1 => "x", 2 => "y" }
  NAMES.each { |code, v|
    const_set("A#{code}", "#{v}!")
    const_set("L#{code}", v)
    const_set("F#{code}", "ab" "cd")
    const_set("G#{code}", "lit")
    const_set("H#{code}", v.to_s)
    const_set("I#{code}", [v, "#{v}?", code])
  }
end
p K::A1, K::A1.frozen?, K::L1.frozen?
p K::F1, K::F1.frozen?, K::G2.frozen?
p K::H1, K::H1.frozen?, K::H1.equal?(K::NAMES[1])
p K::I1, K::I1[0].frozen?, K::I1[1].frozen?, K::I2.frozen?
K::A2 << "?"
K::I1[1] << "!"
p K::A2, K::I1, K::I2
