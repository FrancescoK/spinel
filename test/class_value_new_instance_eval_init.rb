# A constructor that runs its block through instance_eval / instance_exec,
# reached by `new` on a Class value rather than a constant: the dispatch arm
# splices the body with the block as a static `K.new { }` does, so the block
# runs with the new object as self.

class Mm
  attr_reader :e
  def initialize(owner, &)
    @e = [owner]
    instance_eval(&) if block_given?
  end
  def ev(n) = @e << n
end

class Named
  attr_reader :e
  def initialize(owner, &blk)
    @e = [owner]
    instance_eval(&blk) if block_given?
  end
  def ev(n) = @e << n
end

# declares a block it never looks at
class Nn; def initialize(o, &) = nil; end

k = [Mm, Nn].first
p k.new(1) { ev 2 }.e
p k.new(5).e
p Mm.new(3) { ev 4; ev 5 }.e
p [Named, Nn].first.new(1) { ev 2; ev 3 }.e

# a class value whose type is Class, not a boxed value
k2 = ARGV.empty? ? Mm : Nn
p k2.new(7) { ev 8 }.e

class Ex
  attr_reader :log
  def initialize(tag, &b)
    @log = [tag]
    instance_exec(tag * 2, &b) if block_given?
  end
  def add(x) = @log << x
end
kx = [Ex, Nn].first
p kx.new(3) { |d| add d; add d + 1 }.log
p Ex.new(1) { |d| add(d) }.log
p kx.new(9).log

module Conf
  def initialize(o, *args, &)
    @items = [o, *args]
    instance_eval(&) if block_given?
  end
  def item(x) = @items << x
  def items = @items
end
class Cfg; include Conf; end
kc = [Cfg, Nn].first
p kc.new(:a, :b) { item :c }.items
p Cfg.new(:z) { item :y }.items
p kc.new(:q).items

# an inherited instance_eval constructor runs the block as the subclass
class Loud < Mm
  def ev(n) = @e << n * 10
end
p [Loud, Mm].first.new(1) { ev 2 }.e
p Loud.new(1) { ev 3 }.e

# keywords and a yielding (not instance_eval) initialize, zero arguments
class Kw
  attr_reader :v
  def initialize(a, b: 2, &)
    @v = [a, b]
    instance_eval(&) if block_given?
  end
  def put(x) = @v << x
end
kw = [Kw, Nn].first
p kw.new(1, b: 5) { put 6 }.v
p kw.new(1) { put 7 }.v

class Zero
  attr_reader :z
  def initialize
    @z = block_given? ? yield(7) : 42
  end
end
z = [Zero, Nn].first
p z.new { |q| q + 1 }.z
p z.new.z

# with no block at all, instance_eval / instance_exec raise as in CRuby
class Strict
  def initialize(&)
    @s = 1
    instance_eval(&)
  end
end
class StrictX
  def initialize(&)
    @s = 1
    instance_exec(1, &)
  end
end
[-> { Strict.new }, -> { [Strict, Nn].first.new }, -> { [StrictX, Nn].first.new }].each do |f|
  f.call
rescue ArgumentError, LocalJumpError => e
  puts "#{e.class}: #{e.message}"
end
