# An alias names the method in effect where it appears: a module included
# or prepended after it, or a def after it over an included module's
# method, does not change what the alias calls
module Greet
  def hi(name = "x") = "hi #{name}"
end
module Loud
  def hi(name = "x") = "HI #{name}"
end
module Polite
  def hi(name = "x") = "please, " + super
end

# alias-method chain over an included module's method
class A
  include Greet
  alias_method :plain_hi, :hi
  def hi(name = "x") = plain_hi(name) + "!"
end

# a later include, with arguments
class B
  include Greet
  alias old_hi hi
  include Loud
end

# a later prepend whose method calls super
class C
  include Greet
  alias_method :orig, :hi
  prepend Polite
end

# an own def, then the alias, then a prepend
class D
  def hi(name = "x") = "d #{name}"
  alias_method :orig, :hi
  prepend Loud
end

# the include comes in a reopening after the alias
class E
  include Greet
  alias_method :orig, :hi
end
class E
  include Loud
end

# a subclass inherits the alias
class F < B; end

# the alias after every include stays the last one's
class G
  include Greet
  include Loud
  alias_method :orig, :hi
end

# a second alias of the same name replaces the first
class H
  include Greet
  alias_method :orig, :hi
  include Loud
  alias_method :orig, :hi
end

p A.new.hi("a"), A.new.plain_hi("a")
p H.new.orig
p B.new.hi("b"), B.new.old_hi("b")
p C.new.hi("c"), C.new.orig("c")
p D.new.hi("d"), D.new.orig("d")
p E.new.hi("e"), E.new.orig("e")
p F.new.hi("f"), F.new.old_hi("f")
p G.new.hi, G.new.orig
[A.new, B.new, E.new].each { |o| p o.hi }
