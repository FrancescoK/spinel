# A Time handed on as a second argument, after a plain local, to an
# initialize that changes it in place: the caller's Time changes too, as in
# CRuby. (From #9986, where it was refused.)
class Stamp
  def initialize(t)
    x = Time.utc(2026, 10, 15, 1, 0, 0)
    stamp(x, t)
  end

  def stamp(a, b)
    a.localtime(3600)
    b.localtime(3600)
  end
end

a = Time.utc(2026, 10, 15, 1, 0, 0)
Stamp.new(a)
p a.utc_offset
