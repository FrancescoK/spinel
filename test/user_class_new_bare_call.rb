# Bare `new` in a class method reaches the class's own `self.new` when it
# defines one, as does a `new(...)` forward, and a subclass inheriting the
# forwarder builds itself through it; the method called on the result then
# dispatches on the runtime class (#5405).
class Base
  class << self
    def call(...)
      new(...).run
    end
    def new(*a, **k)
      super
    end
  end
  def run = :base
end
class Mid < Base
  def run = :mid
end
p Base.call
p Mid.call

class Base2
  @@made = 0
  class << self
    def call(...) = new(...).run
    def new(*a, **k)
      @@made += 1
      super
    end
    def made = @@made
  end
  def initialize(x = 1, tag: :t) = (@x = x; @tag = tag)
  def run = [:base, @x, @tag]
end
class Mid2 < Base2
  def run = [:mid, @x, @tag]
end
p Base2.call, Mid2.call(5), Mid2.call(6, tag: :z)
p Base2.made, Mid2.made

class Base3
  class << self
    def call(*a)
      new(*a).run
    end
    def new(*a, **k)
      super
    end
  end
  def run = :base
end
class Mid3 < Base3
  def run = :mid
end
p Base3.call
p Mid3.call
