# A parameter a method never reassigns, handed on to another call, is copied
# into the call's argument temp; the parameter's own root holds it, so the
# copy takes none. Run under SPINEL_GC_STRESS=1 the value must survive the
# later arguments' allocations and the callee's. A parameter the method does
# reassign, or one a block captures, keeps the rooted copy.
class Num
  attr_reader :v
  def initialize(v); @v = v; end
end

class Add
  attr_reader :l, :r
  def initialize(l, r); @l = l; @r = r; end
end

class Var
  attr_reader :name
  def initialize(n); @name = n; end
end

class Interp
  def visit(node, env)
    if node.is_a?(Num)
      node.v
    elsif node.is_a?(Var)
      env[node.name]
    elsif node.is_a?(Add)
      visit(node.l, env) + visit(node.r, env)
    else
      0
    end
  end

  # the parameter is reassigned: its copy keeps a root
  def walk(node, env)
    env = env.merge({ "z" => 100 }) if node.is_a?(Add)
    node.is_a?(Add) ? walk(node.l, env) + walk(node.r, env) : visit(node, env)
  end

  # a String parameter handed on beside fresh allocations
  def label(tag, n)
    n == 0 ? tag : fmt(tag, "#{n}:" + "x" * n) + label(tag, n - 1)
  end

  def fmt(tag, body) = "<#{tag}>#{body}"
end

tree = Add.new(Add.new(Num.new(1), Var.new("a")), Add.new(Var.new("b"), Num.new(4)))
ip = Interp.new
puts ip.visit(tree, { "a" => 10, "b" => 20 })
puts ip.walk(tree, { "a" => 1, "b" => 2, "z" => 0 })
puts ip.label("t", 3)

# a poly parameter, handed on to a method that allocates before it reads it
def keep(x, n) = n == 0 ? [x, x.class.name] : keep(x, n - 1) + [n.to_s * 2]
p keep([1, "s"], 2)
p keep("str", 1)
p keep(nil, 1)

# a block captures the parameter
def capture(h)
  add = -> { h = h.merge({ k: h.size }) }
  add.call
  show(h, [1, 2].map { |v| v * 2 })
end
def show(h, xs) = "#{h} #{xs}"
puts capture({ a: 1 })
