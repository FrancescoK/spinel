# `v.to_s(16)` on a boxed value when a user class defines its own `to_s`: the
# dispatch has the user arm (raising ArgumentError for a user receiver, as
# CRuby does) and still answers Integer#to_s(base) for a genuine Integer.
class B
  def to_s = "B!"
end
class A
  def initialize(x) = @a = x
  def hex = "0x#{@a.to_s(16)}"
  def show = @a.to_s
end
p A.new(255).hex
p A.new(B.new).show
p A.new(3.5).show
