# a class-level accessor (`class << self; attr_accessor :x; end`) holding an
# Integer or a Float, read through self.class from an instance method

class C0
  class << self
    attr_accessor :x
  end
  @x = 1
  def get = self.class.x
end
p C0.x
p C0.new.get

class A
  class << self
    attr_accessor :x
  end
  def get = self.class.x
  def twice = self.class.x * 2
end
p A.new.get
A.x = 3
p A.new.get
p A.new.twice
class B
  class << self
    attr_accessor :f
  end
  @f = 1.5
  def get = self.class.f
end
p B.new.get

# a class-level slot set back to nil, and one that may be
class E
  class << self
    attr_accessor :x
  end
  @x = 1
  def get = self.class.x
end
p E.new.get
E.x = nil
p E.new.get
class F
  class << self
    attr_accessor :y
  end
  def get = self.class.y
end
p F.new.get
x = F.new.get
p x
class G
  class << self
    attr_accessor :z
  end
  @z = 2
  def get = self.class.z
end
G.z = nil if ARGV.size > 5
p G.new.get
