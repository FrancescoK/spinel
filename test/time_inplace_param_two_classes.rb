# A method reached through a receiver of more than one class that changes
# a Time argument in place by #localtime: the caller's Time changes too, as
# in CRuby. (From #9986, where it was refused.)
class A
  def shift(t) = t.localtime(3600)
end
class B
  def shift(t) = t.localtime(7200)
end

a = Time.utc(2026, 10, 15, 1, 0, 0)
[A.new, B.new].each { |o| o.shift(a) }
p a.utc_offset
