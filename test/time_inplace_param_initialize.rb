# An initialize that changes the Time it is given by #localtime changes the
# caller's Time too: a Time is a reference, as in CRuby. (From #9986,
# where it was refused.)
class Stamp
  def initialize(t) = t.localtime(3600)
end

a = Time.utc(2026, 10, 15, 1, 0, 0)
Stamp.new(a)
p a.utc_offset
