# A user override keeps its own return route instead of builtin clamp's.
class String
  def clamp(lo, hi)
    hi
  end
end
s = +"middle"
lo = +"lower"
hi = +"upper"
t = s.clamp(lo, hi)
t << "!"
p [s, lo, hi, t, hi.equal?(t)]
