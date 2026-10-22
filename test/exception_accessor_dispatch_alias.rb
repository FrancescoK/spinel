# An alias named after an exception accessor answers for its own class's
# objects beside a real exception of that kind, read through one block.
module M1
  def params = [:m1]
  alias key params
end
class A1; include M1; end
k = KeyError.new("x", key: :kk)
[A1.new, k].each { |x| p((x.key rescue $!.message)) }

class A2
  def params = [:a2]
  alias_method :key, :params
end
[A2.new, k].each { |x| p((x.key rescue $!.message)) }

class A3
  def params = [:a3]
  alias result params
end
[A3.new, StopIteration.new].each { |x| p((x.result rescue $!.message)) }

class A4
  def m = :a4
  alias message m
end
[A4.new, RuntimeError.new("boom")].each { |x| p((x.message rescue $!.message)) }
