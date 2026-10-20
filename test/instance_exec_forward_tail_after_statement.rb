# A method that hands its block on with `instance_exec(*args, &block)` as the
# value it ends with, after another statement or in a parenthesized sequence,
# called with blocks that answer different kinds. A method whose body is the
# forward alone is a trampoline, typed per call site; one with a statement
# before it answered the first site's kind at every site, so a String block
# was assigned into an Integer slot and the C did not build. The forward is
# the method's value as a tail `yield` is, and each site answers its own
# block's.
class Rel
  def initialize(n) = @n = n

  def run(*args, &block)
    @n += 1
    instance_exec(*args, &block)
  end

  def run_seq(*args, &block)
    (@n += 1; instance_exec(*args, &block))
  end

  def run_one(&block)
    @n += 1
    instance_exec(&block)
  end

  def run_branch(&block)
    @n += 1
    if @n > 0
      instance_exec(&block)
    else
      nil
    end
  end

  def run_self(&block)
    @n += 1
    [1].each { }
    self.instance_exec(&block)
  end
end

r = Rel.new(10)
p r.run { @n + 1 }
p r.run(2) { |a| "n=#{@n * a}" }
p r.run_seq { @n + 1 }
p r.run_seq(2) { |a| "n=#{@n * a}" }
p r.run_one { @n + 1 }
p r.run_one { "s#{@n}" }
p r.run_one { [@n] }
p r.run_branch { @n + 1 }
p r.run_branch { "s#{@n}" }
p r.run_self { @n + 1 }
p r.run_self { "s#{@n}" }

# a forward on a receiver of another known class runs the block as that class
class Rec
  def initialize; @v = 1; end
end

class Holder
  def initialize; @r = Rec.new; end

  def go(&block)
    @x = 1
    @r.instance_exec(&block)
  end
end

h = Holder.new
p h.go { @v + 1 }
p h.go { "s#{@v}" }
