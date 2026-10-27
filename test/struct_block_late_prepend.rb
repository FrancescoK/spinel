# a prepend in a later `class Name` reopening of a Struct.new / Data.define
# class takes effect when the reopening runs: a call before it answers
# without the later module
module LateP1; def t = "p1" + super; end
module LateP2; def t = "p2" + super; end
LateT = Struct.new(:x) do
  prepend LateP1
  def t = "t"
end
p LateT.new(1).t
class LateT
  prepend LateP2
end
p LateT.new(1).t

LateD = Data.define(:x) do
  def t = "d"
end
p LateD.new(x: 1).t
class LateD
  prepend LateP1
end
p LateD.new(x: 1).t
