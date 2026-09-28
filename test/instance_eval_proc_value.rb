# instance_eval / instance_exec whose block is a Proc value -- a stored
# proc, or a block a dispatch turned into one -- runs it with the receiver
# as self, as a literal block does.

class M
  attr_reader :log
  def initialize(name, &)
    @log = [name]
    instance_eval(&) if block_given?
  end
  def ev(x) = @log << x
  def self.build(name, &) = new(name, &)
end

class Owner
  def self.sm(name, &) = M.build(name, &)
end

blk = proc { ev 3 }
p M.new(:c, &blk).log
p [Owner, nil].first.sm(:a) { ev 1 }.log
p Owner.sm(:b) { ev 2 }.log

# ivars and a captured local in the proc body
n = 5
iv = proc { @log << n; ev(@log.size) }
p M.new(:e, &iv).log
p M.build(:f, &iv).log

# instance_eval hands the receiver to the proc's parameter, and answers
# the proc's value
me = proc { |o| o.ev(:me); ev(o.equal?(self)) }
p M.new(:g, &me).log
size = proc { @log.size * 100 }
p M.new(:h).instance_eval(&size)

# instance_exec passes its arguments, to a lambda too, and a trampoline
# method forwards the proc
class Acc
  attr_reader :sum
  def initialize = @sum = 0
  def add(x) = @sum += x
  def run(&b) = instance_eval(&b)
  def run_with(x, &b) = instance_exec(x, &b)
end
twice = ->(v) { add(v * 2); @sum }
a = Acc.new
p a.run_with(4, &twice)
p a.instance_exec(10, &twice)
bump = proc { add 1 }
p a.run(&bump)
p a.sum

# a proc built in another class's method runs as the receiver
class Other
  def initialize = @log = :other
  def go
    pr = proc { ev @log.size }
    M.new(:i, &pr)
  end
end
p Other.new.go.log

# nested: the proc instance_evals another proc on another object
inner = proc { add 7 }
acc = Acc.new
outer = proc { ev(acc.instance_eval(&inner)) }
p M.new(:j, &outer).log


# a proc spinel cannot trace to the receiver raises NotImplementedError
# rather than run with its definition-site self
class Holder
  attr_reader :log, :pr
  def initialize
    @log = []
    @pr = proc { @log << :held }
  end
end
h = Holder.new
r = begin
  M.new(:k, &h.pr).log
rescue NotImplementedError => e
  e.class
end
p [r == [:k, :held] || r == NotImplementedError, h.log]
