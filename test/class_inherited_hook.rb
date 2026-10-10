# `class A < Base` calls Base.inherited(A) as A is created, before its body
# runs: once per class (a reopening does not call it), through the nearest
# ancestor that defines it, and also when the hook is private or lives in
# `class << self`. Its `super` reaches Class#inherited, which does nothing.
class Base
  @subs = []
  def self.subs = @subs
  def self.inherited(sub)
    super
    Base.subs << sub
    puts "inherited #{sub} into #{self}"
  end
end
class A < Base
  puts "A's body"
end
class A < Base
end
class A
  def hi = "hi"
end
class B < A; end
module NS
  class C < ::Base; end
  class A < Base; end
end
class Plain; end
class Q < Plain; end

class T
  class << self
    def inherited(k)
      super
      puts "T got #{k}"
    end
  end
end
class U < T; end

class Base2 < Base
  def self.inherited(k)
    super
    puts "Base2 got #{k}"
  end
end
class V < Base2; end

class Plugin
  @registry = {}
  class << self
    attr_reader :registry
    def label = name.downcase
  end
  def self.inherited(sub)
    super
    Plugin.registry[sub.label] = sub
  end
  private_class_method :inherited
  def run = "#{self.class.name} runs"
end
class Alpha < Plugin; end
class Beta < Plugin
  def run = "beta!"
end

p Base.subs
p Base.subs.map(&:name)
p A.new.hi
p Plugin.registry.keys
p Plugin.registry.values.map { |k| k.new.run }
