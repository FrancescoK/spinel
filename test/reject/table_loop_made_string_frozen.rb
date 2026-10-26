# A String the loop computes and freezes through another local: the
# evaluator keeps a value per local, so it does not follow the freeze, and
# the loop stays as written, which Spinel refuses.
module K
  NAMES = { 1 => "x" }
  NAMES.each { |code, v|
    s = "#{v}!"
    t = s
    t.freeze
    const_set("A#{code}", s)
  }
end
p K::A1, K::A1.frozen?
