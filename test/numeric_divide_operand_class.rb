# Float#modulo and Integer#div / #modulo given an operand with no number in
# it. Float#modulo's row bound any operand into sp_fmod's double slot, and
# the Integer arms bound it into sp_idiv's or sp_imod's sp_int slot, so an
# Array, a String or a boxed value did not build. CRuby coerces the operand
# and raises "X can't be coerced into Float" (or Integer); a Numeric divides
# as before. (A boxed operand of another class keeps the boxed conversion's
# own message, as `%` does.)

def t(k)
  f = k == 0 ? 0.3 : nil
  a = [7]
  s = "s"
  h = {1 => 2}
  p(begin; f.modulo(s); rescue TypeError => e; e.message; end)
  p(begin; f.modulo(:q); rescue TypeError => e; e.message; end)
  p(begin; f.modulo(h); rescue TypeError => e; e.message; end)
  p(begin; f.modulo(true); rescue TypeError => e; e.message; end)
  p f.modulo(2), f.modulo(2.5), f.modulo(Rational(1, 4))
  p(begin; f.modulo(a); rescue TypeError => e; e.message; end)
  p(begin; 7.div(a); rescue TypeError => e; e.message; end)
  p(begin; 7.modulo(s); rescue TypeError => e; e.message; end)
  p(begin; 7.div(:q); rescue TypeError => e; e.message; end)
  p(begin; 7.modulo(h); rescue TypeError => e; e.message; end)
  p f.modulo([0.2, 1][k])
  p 0.3.modulo(2)
  p 7.div(2), 7.modulo(3)
end

t(ARGV.size)
