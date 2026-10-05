# Range#cover? on a Range read out of a box (one that may be nil) given an
# argument of a class other than a number or a Range: a String, an Array,
# nil. The boxed dispatch's Range arm passed such an argument to
# sp_range_include's sp_int slot, and the generated C did not build; it
# compares boxed now, as a boxed argument does. A String Range had no arm in
# that dispatch and answered false, where it covers by string comparison.

def t(k)
  ir = k == 0 ? (1..3) : nil
  fr = k == 0 ? (0.5..2.5) : nil
  sr = k == 0 ? ("a".."c") : nil
  a = [7]
  p ir.cover?(a), ir.cover?("b"), ir.cover?(nil), ir.cover?(2), ir.cover?(2.5)
  p fr.cover?(a), fr.cover?("b"), fr.cover?(1), fr.cover?(1.5)
  p sr.cover?(a), sr.cover?("b"), sr.cover?("z"), sr.cover?(nil)
  bx = [(1..3), "s"][k]
  p bx.cover?("b"), bx.cover?(:s)
end

t(ARGV.size)
