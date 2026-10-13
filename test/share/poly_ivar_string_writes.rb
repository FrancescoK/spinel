# A boxed instance variable written a Hash in one place and a String in
# another is changed in place through its reader, so the String shares with
# every name that holds it, whichever way the String is written: an
# attribute writer (a name with non-ASCII letters too), its `||=`, a
# multiple write, instance_variable_set, a send or a Method naming the
# writer, instance_exec, a define_method body, `+=` on the ivar and an
# operator write through the attribute (`o.x *= ","`). Each shape has an
# ivar of its own name: one String write of a name reaches every ivar of
# that name.
class W1
  attr_accessor :v1
  def initialize = (@v1 = {})
end
ow1 = W1.new
ow1.v1["k"] = 1
s1 = +"writer"
ow1.v1 = s1
ow1.v1 << "+"

class W2
  attr_accessor :v2
  def initialize = (@v2 = {})
end
ow2 = W2.new
ow2.v2["k"] = 1
s2 = +"or"
ow2.v2 = nil
ow2.v2 ||= s2
ow2.v2 << "+"

class W3
  attr_accessor :v3
  def initialize = (@v3 = {})
end
ow3 = W3.new
ow3.v3["k"] = 1
s3 = +"multi"
ow3.v3, n = s3, 1
ow3.v3 << "+"

class W4
  attr_reader :v4
  def initialize = (@v4 = {})
end
ow4 = W4.new
ow4.v4["k"] = 1
s4 = +"ivset"
ow4.instance_variable_set(:@v4, s4)
ow4.v4 << "+"

class W5
  attr_accessor :v5
  def initialize = (@v5 = {})
end
ow5 = W5.new
ow5.v5["k"] = 1
s5 = +"send"
ow5.send(:v5=, s5)
ow5.v5 << "+"

class W6
  attr_accessor :v6
  def initialize = (@v6 = {})
end
ow6 = W6.new
ow6.v6["k"] = 1
s6 = +"method"
ow6.method(:v6=).call(s6)
ow6.v6 << "+"

class W7
  attr_reader :v7
  def initialize = (@v7 = {})
end
ow7 = W7.new
ow7.v7["k"] = 1
s7 = +"exec"
ow7.instance_exec(s7) { |v| @v7 = v }
ow7.v7 << "+"

class W8
  attr_reader :v8
  def initialize = (@v8 = {})
  define_method(:load) { |v| @v8 = v }
end
ow8 = W8.new
ow8.v8["k"] = 1
s8 = +"define"
ow8.load(s8)
ow8.v8 << "+"

class W9
  attr_reader :v9
  def initialize(v) = (@v9 = v)
  def bump = (@v9 += "!")
end
W9.new({})
ow9 = W9.new(+"op")
ow9.bump
t9 = ow9.v9
ow9.v9 << "+"

class W10
  attr_accessor :ítem
  def initialize = (@ítem = {})
end
ow10 = W10.new
ow10.ítem["k"] = 1
s10 = +"accent"
ow10.ítem = s10
ow10.ítem << "+"

class W11
  attr_accessor :itém
  def initialize = (@itém = {})
end
ow11 = W11.new
ow11.itém["k"] = 1
s11 = +"accent-send"
ow11.send(:itém=, s11)
ow11.itém << "+"

class W12
  attr_accessor :v12
  def initialize(v) = (@v12 = v)
end
W12.new({}).v12["k"] = 1
ow12 = W12.new(["a", "b"])
ow12.v12 *= ","
t12 = ow12.v12
ow12.v12 << "+"
p s1, s2, n, s3, s4, s5, s6, s7, s8, t9, s10, s11, t12
