# A singleton alias (`class << self; alias a b`) is a class method: the
# class responds to its name and an instance does not, while an instance
# alias is the other way round, whether the name is a literal or not.
class A
  def self.b = 1
  def b = 2
  class << self
    alias a b
  end
  def c = 3
  alias d c
end
p A.respond_to?(:a), A.new.respond_to?(:a)
p A.new.respond_to?(:d), A.respond_to?(:d)
[:a, :b, :d].each { |m| p [m, A.new.respond_to?(m)] }
class Sub < A; end
p Sub.new.respond_to?(:a), Sub.respond_to?(:a)
p A.instance_methods(false).sort, A.singleton_methods.sort

# an instance method beside a singleton alias of the same name stays the
# instance's; a writer beside a singleton alias of its name answers for an
# instance; a private class method or singleton alias is no singleton method
class K
  def foo = "K#foo"
  def self.bar = "K.bar"
  attr_writer :x
  def self.y=(v)
    v
  end
  def self.hidden = 0
  private_class_method :hidden
  class << self
    alias foo bar
    alias x= y=
    alias quiet bar
    private :quiet
  end
end
w = :x=
p K.new.foo, K.foo, K.new.respond_to?(:foo), K.new.respond_to?(:x=), K.new.respond_to?(w)
p K.instance_methods(false).sort, K.singleton_methods.sort
