# instance_variable_set/get on a class value the method can only see at run time:
# the subclass handed to inherited, and self.class in an instance method.
# Each subclass keeps its own slot.
class Base
  @req = { a: 1 }
  class << self
    attr_reader :req
  end
  def self.inherited(subclass)
    super
    subclass.instance_variable_set(:@req, req.dup)
  end
end
class Child < Base; end
class Other < Base; end
Child.req[:b] = 2
p Base.req, Child.req, Other.req
p Child.instance_variable_get(:@req)

class Counter
  @hits = 0
  def self.hits = @hits
  def hit
    self.class.instance_variable_set(:@hits, self.class.instance_variable_get(:@hits) + 1)
  end
end
class SubCounter < Counter
  @hits = 10
end
Counter.new.hit
SubCounter.new.hit
SubCounter.new.hit
p Counter.hits, SubCounter.hits

class Reg
  @names = []
  class << self
    attr_reader :names
    def inherited(k)
      super
      k.instance_variable_set(:@names, [k.name])
    end
  end
end
class RegA < Reg; end
p Reg.names, RegA.names

p Base.singleton_methods.sort, Child.singleton_methods.sort
p Base.respond_to?(:req)
p Counter.singleton_methods.sort, SubCounter.singleton_methods.sort
