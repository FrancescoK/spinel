# A class's own ==, eql? or equal? answers for itself whatever the operand.
# The equality emitter folded an object == a Hash to false ("hash vs a
# concrete non-hash: never equal") before the receiver's == was dispatched,
# so a test harness's `x.should == {"a" => "1"}` never ran its check. A
# Struct's own eql?, and any class's own equal?, were passed over the same
# way, for every operand.

class E
  def ==(o) = (puts "E#== #{o.class}"; true)
end
p(E.new == {"a" => "b"})
p(E.new == {a: 1})
h = {"k" => 1}
p(E.new == h)
p(E.new != {"a" => "b"})

class C
  include Comparable
  def <=>(o) = (puts "C#<=> #{o.class}"; 0)
end
p(C.new == {"a" => "b"})

class B < E; end
p(B.new == {"a" => "b"})

module M
  def ==(o) = o.size
end
class F; include M; end
p(F.new == {"a" => 1, "b" => 2})

class Plain; end
p(Plain.new == {"a" => "b"})
p(Plain.new != {"a" => "b"})

S = Struct.new(:a) do
  def ==(o) = (puts "S#== #{o.class}"; true)
  def eql?(o) = (puts "S#eql? #{o.class}"; true)
end
p(S.new(1) == {"a" => 1})
p S.new(1).eql?({"a" => 1})
p S.new(1).eql?([1])
p S.new(1).eql?(S.new(2))
T = Struct.new(:a)
p T.new(1).eql?(T.new(1))
p T.new(1) == {"a" => 1}

class Same
  def equal?(o) = (puts "Same#equal? #{o.class}"; true)
end
p Same.new.equal?({"a" => 1})
p Same.new.equal?(1)
p Object.new.equal?(1)

class Expect
  def initialize(v) = (@v = v)
  def ==(o) = (puts(@v == o ? "pass" : "fail"); true)
end
class Object
  def should = Expect.new(self)
end
{"a" => "1"}.should == {"a" => "1"}
{"a" => "1"}.should == {"a" => "2"}
