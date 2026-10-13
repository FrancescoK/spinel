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
