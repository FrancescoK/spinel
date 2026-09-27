# A `.new` dispatched over several classes, reaching a constructor whose
# omitted default calls a method on the new object. The positional arms
# dropped such a class (NoMethodError at run time), and the zero-argument
# and keyword arms emitted a `self` the caller does not have.

class Scaled
  def initialize(n, s = scale(n))
    @s = s
  end

  def scale(n) = n * 10
  def show = puts("Scaled #{@s}")
end

class Limited
  def initialize(n = 2, s = limit + n)
    @s = s
  end

  def limit = 100
  def show = puts("Limited #{@s}")
end

class Plain
  def initialize(n = 1)
    @n = n
  end

  def show = puts("Plain #{@n}")
end

class Keyed
  def initialize(n, extra: 0, s: n + extra + bonus)
    @s = s
  end

  def bonus = 1000
  def show = puts("#{self.class} #{@s}")
end

class SubKeyed < Keyed
  def bonus = 2000
end

def make(klass, n) = klass.new(n)
make(Scaled, 4).show
make(Limited, 5).show
make(Plain, 6).show
[Scaled, Limited, Plain].each { |k| k.new(7).show }

def make0(klass) = klass.new
make0(Limited).show
make0(Plain).show
[Limited, Plain].each { |k| k.new.show }

def make_kw(klass, n) = klass.new(n, extra: 3)
make_kw(Keyed, 1).show
make_kw(SubKeyed, 2).show
[Keyed, SubKeyed].each { |k| k.new(5, extra: 1).show }
