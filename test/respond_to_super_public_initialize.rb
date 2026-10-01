# A respond_to? override that calls super answers :initialize as public when
# the class made it public with `public :initialize`, whether or not the
# class chain defines initialize itself, and as private otherwise.
class B
  def respond_to?(n, *) = super
  public :initialize
end
p B.new.respond_to?(:initialize)

class C
  def respond_to?(n, *) = super
  def initialize; end
  public :initialize
end
p C.new.respond_to?(:initialize), C.new.respond_to?(:initialize, true)

class D
  def respond_to?(n, *) = super
  def initialize; end
end
p D.new.respond_to?(:initialize), D.new.respond_to?(:initialize, true)

class E < D
  public :initialize
end
p E.new.respond_to?(:initialize)

class F
  def respond_to?(n, *) = super
end
p F.new.respond_to?(:initialize), F.new.respond_to?(:initialize, true)
