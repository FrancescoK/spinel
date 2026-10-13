# A boxed receiver that names an attribute reader is read by the ivar's
# writes only if every class the receiver can be answers the name with that
# reader. Here each reader is answered by something else that hands out a
# String -- a subclass's def, a singleton method, an extended or a
# prepended module, a memo, a `return`, a Struct member -- so the append
# through it is a String mutation, and the String shares.
class R1
  attr_accessor :r1
  def initialize = (@r1 = {})
end
class R1Str < R1
  def initialize(s)
    super()
    @s = s
  end
  def r1 = @s
end
def grow1(o) = (o.r1 << "+")
s1 = +"sub"
grow1(R1Str.new(s1))
h = R1.new
h.r1["k"] = 1
grow1(h) rescue p $!.class

class R2
  attr_accessor :r2
  def initialize = (@r2 = {})
end
S2 = +"single"
o2 = R2.new
def o2.r2 = S2
o2.r2 << "+"
R2.new.r2["k"] = 1

module StrReader
  def r3 = $s3
end
$s3 = +"extend"
class R3
  attr_accessor :r3
  def initialize = (@r3 = {})
end
o3 = R3.new
o3.extend(StrReader)
o3.r3 << "+"
R3.new.r3["k"] = 1

$s4 = +"prepend"
module StrReader4
  def r4 = $s4
end
class R4
  attr_accessor :r4
  def initialize = (@r4 = {})
end
class R4P < R4
  prepend StrReader4
end
def grow4(o) = (o.r4 << "+")
grow4(R4P.new)
R4.new.r4["k"] = 1

class R5
  def initialize(seed) = (@seed = seed)
  def r5 = (@r5 ||= @seed)
end
s5 = +"memo"
R5.new(s5).r5 << "+"
R5.new({}).r5["k"] = 1

class R6
  def initialize(s, f)
    @r6 = {}
    @s = s
    @f = f
  end
  def r6
    return @s if @f
    @r6
  end
end
s6 = +"early"
R6.new(s6, true).r6 << "+"
R6.new(s6, false).r6["k"] = 1

R7 = Struct.new(:r7, :n)
s7 = +"struct"
R7.new(s7, 1).r7 << "+"
R7.new({}, 2).r7["k"] = 1
p s1, S2, $s3, $s4, s5, s6, s7
