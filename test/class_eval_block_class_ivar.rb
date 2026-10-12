# An @x in a block that class_eval runs on a class is that class's own ivar,
# the one its class methods see, wherever the call stands. So is a read in
# one instance_eval runs on it.
class A
  def self.z = @z
  def self.zdef = defined?(@z)
end
p A.zdef
A.class_eval { @z = 7 }
p A.z
p A.zdef
p defined?(@z)
p @z

# op-writes, a nested block, the call's value
module B
  def self.n = @n
end
v = B.module_eval do
  @n ||= 1
  @n += 2
  [1, 2].each { |i| @n += i }
  @n * 10
end
p v
p B.n

# from an instance method: the instance's @z is its own
class Inst
  def initialize; @z = :inst; end
  def go
    A.class_eval { @z = 9 }
    @z
  end
end
p Inst.new.go
p A.z

# from a class method of another class, and inside that class's own body
class G
  def self.w = @w
end
class H
  def self.setup = G.class_eval { @w = [1, 2] }
  G.class_eval { @w2 = :body }
end
H.setup
p G.w
p G.instance_variable_get(:@w2)

# reads, defined?, and a body ivar the class already has
class R
  @r = 5
  [1].each { @r += 1 }
  def self.r = @r
end
p R.class_eval { @r }
p R.class_eval { defined?(@r) }
p R.class_eval { defined?(@nope) }
R.class_eval { @r = nil }
p R.class_eval { defined?(@r) }
p R.r

# a String, and a lambda that runs later
class S
  def self.s = @s
end
f = S.class_eval do
  @s = +"a"
  @s << "b"
  -> { @s << "c" }
end
f.call
p S.s

# class_exec with an argument
class X
  def self.x = @x
end
p X.class_exec(5) { |a| @x = a * 2 }
p X.x
# reads in a block instance_eval / instance_exec runs on the class
p X.instance_eval { @x }
p X.instance_exec(1) { |a| [@x, a] }
p X.instance_eval { [defined?(@x), defined?(@nope)] }

# a block given to Array.new keeps the class as self; one a method runs
# with instance_exec does not
class W
  def initialize; @x = :w; end
  def run(&b) = instance_exec(&b)
end
class Bld
  attr_reader :x
  def self.build(&b) = new.tap { |o| o.instance_exec(&b) }
end
class Y
  def self.x = @x
end
w = W.new
k = Bld
p Y.class_eval { @x = 7; Array.new(2) { @x } }
p Y.class_eval { w.run { @x } }
p Y.class_eval { k.build { @x = 5 } }.x
p Y.x
