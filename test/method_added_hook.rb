# Module#method_added: called with the name after each `def` in a class body,
# with self the class whose body ran it (so class-level ivars are that class's).
module Registry
  def method_added(name)
    @seen ||= []
    @seen << [name, public_method_defined?(name)]
  end

  def seen
    @seen || []
  end
end

class Base
  extend Registry

  def first; end

  def self.not_an_instance_method; end

  private

  def hidden; end
end

class Child < Base
  def second; end
  def third(a, b = 1); end
end

class Grandchild < Child
  def fourth; end
end

class Plain
  def untouched; end
end

p Base.seen
p Child.seen
p Grandchild.seen
p Plain.respond_to?(:seen)

class Counter
  def self.method_added(name)
    @count = (@count || 0) + 1
    @last = name
  end

  def self.report
    [@count, @last]
  end

  def a; end
  def b; end
end
p Counter.report
