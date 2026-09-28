# An exception class whose initialize takes a block (`&blk`, or yields) runs
# that initialize when it is raised, from a constant or a Class value, and when
# its `new` passes a block.

class Blk < StandardError
  def initialize(m = "b", &blk) = super("blk #{m}")
end
begin; raise Blk, "boom"; rescue => e; p e.message; end
k = Blk
begin; raise k, "boom"; rescue => e; p e.message; end
begin; raise k; rescue => e; p e.message; end
begin; raise Blk; rescue => e; p e.message; end
p Blk.new("x").message

class Yl < StandardError
  def initialize(m = "y")
    v = block_given? ? yield : "nob"
    super("yl #{m} #{v}")
  end
end
class Sub < Yl; end
begin; raise Yl, "boom"; rescue => e; p e.message; end
begin; raise Sub, "boom"; rescue => e; p [e.class, e.message]; end
k = Yl
begin; raise k, "boom"; rescue => e; p e.message; end
begin; raise k; rescue => e; p e.message; end
begin; raise Yl; rescue => e; p e.message; end
k = Sub
begin; raise k, "s"; rescue => e; p e.message; end
p Yl.new("x") { "b" }.message
p Yl.new("x").message

class Base < StandardError
  attr_reader :tag
  def initialize(m = "base")
    @tag = block_given? ? yield : :none
    super("base #{m}")
  end
end
class Mid < Base
  def initialize(m = "mid")
    super("mid #{m}")
  end
end
class Own < Base
  def initialize(m = "own")
    super("own #{m}") { :given }
  end
end
class NoSuper < StandardError
  def initialize(m = "ns")
    yield if block_given?
  end
end
[Base, Mid, Own, NoSuper].each do |kl|
  begin
    raise kl, "r"
  rescue => e
    p [e.class, e.message]
  end
  begin
    raise kl
  rescue => e
    p [e.class, e.message]
  end
end
x = Base.new("obj") { :blk }
p [x.message, x.tag]
p Own.new("n").tag
p NoSuper.new.message

class Calc < StandardError
  attr_reader :n
  def initialize(m = "calc", base = 2)
    @n = block_given? ? yield(base) : base
    super("#{m}: #{@n}")
  end
end
p Calc.new("a") { |v| v * 21 }.n
begin; raise Calc, "r"; rescue Calc => e; p e.message; end
kc = Calc
begin; raise kc; rescue Calc => e; p e.message; end

class P
  attr_reader :v
  def initialize(a)
    @v = block_given? ? yield(a) : a * 2
  end
end
kp = P
p kp.new(5).v
p P.new(2) { |v| v * 10 }.v
