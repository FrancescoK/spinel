# A yielding initialize is spliced into each `new` call site. Its arguments
# and its optional parameters' defaults are evaluated once.

def arg(tag, v)
  puts tag
  v
end

class Built
  def initialize(a, b = (puts "default b"; 1))
    @v = yield(a, b)
  end
  attr_reader :v
end
p Built.new(3) { |x, z| x + z }.v
p Built.new(arg("arg a", 3), arg("arg b", 4)) { |x, z| x + z }.v

class Boxed
  def initialize(a, b = (puts "default boxed"; 1))
    @s = "s"
    @v = yield(a, b)
  end
  attr_reader :v
end
p Boxed.new(arg("arg boxed", 2)) { |x, z| x * z }.v

class Kw
  def initialize(a, k: (puts "default k"; 2))
    @v = yield(a, k)
  end
  attr_reader :v
end
p Kw.new(1) { |x, y| x + y }.v
p Kw.new(1, k: arg("arg k", 5)) { |x, y| x + y }.v

class Str
  def initialize(s, arr = (puts "default arr"; [1, 2]))
    @v = yield(s, arr)
  end
  attr_reader :v
end
p Str.new(arg("arg s", "n")) { |x, y| x + y.size.to_s }.v

class One
  def initialize(a, b = (puts "default one"; 1))
    @v = yield(a, b)
  end
  attr_reader :v
end
class Two
  def initialize(a, b = (puts "default two"; 10))
    @v = yield(a, b)
  end
  attr_reader :v
end
[One, Two].each { |k| p k.new(arg("arg k.new", 5)) { |x, z| x + z }.v }

class Parent
  def initialize(a, b = (puts "default parent"; 1))
    @v = yield(a, b)
  end
  attr_reader :v
end
class Child < Parent
  def initialize(a)
    super(a) { |x, z| x * z + 100 }
  end
end
p Child.new(arg("arg child", 5)).v

class NoBlock
  def initialize(a = (puts "default noblock"; 1))
    @v = a
    yield if block_given?
  end
  attr_reader :v
end
p NoBlock.new.v

class Pt
  def initialize(x) = @x = x
  attr_reader :x
end
class Holder
  def initialize(pt = (puts "default pt"; Pt.new(9)))
    @v = yield(pt)
  end
  attr_reader :v
end
p Holder.new { |pt| pt.x + 1 }.v
