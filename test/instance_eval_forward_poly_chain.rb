class W1
  def initialize(x)
    @x = x
  end

  def run(&b)
    @x.run(&b)
  end
end

class W2
  def initialize(x)
    @x = x
  end

  def run(&b)
    @x.run(&b)
  end
end

class W3
  def initialize(x)
    @x = x
  end

  def run(&b)
    @x.run(&b)
  end
end

class Leaf
  def run(&b)
    instance_eval(&b)
  end

  def v
    7
  end
end

obj = Leaf.new
obj = W1.new(obj)
W1.new(Leaf.new)
obj = W2.new(obj)
W2.new(Leaf.new)
obj = W3.new(obj)
W3.new(Leaf.new)

p obj.run { v }
p W2.new(Leaf.new).run { v + 1 }
