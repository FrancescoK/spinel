# spinel: share
# spinel: gc-minor
# Class.new(Base) resolves Base from where it is written, as a constant read
# does: a module of the same leaf name in another namespace is not the
# superclass, and a module that resolves is still a TypeError.
module Outer
  module Base; end
end
class Base
  def hi = :hi
end
C = Class.new(Base)
p C.superclass
p C.new.hi

# the lexical Base is a class, the top-level one a module
module Base2; end
module Outer2
  class Base2
    def hey = :hey
  end
  D = Class.new(Base2)
end
p Outer2::D.superclass
p Outer2::D.new.hey

# a qualified name resolves through its path
module Space
  class Plain; def plain = :plain; end
  module Mixin; end
end
module Other
  class Mixin; def mix = :mix; end
end
F = Class.new(Other::Mixin)
p F.superclass
p F.new.mix
G = Class.new(Space::Plain)
p G.new.plain

# a name that does resolve to a module is still refused as CRuby does
begin
  Class.new(Outer::Base)
rescue TypeError => e
  puts e.message
end
module Lex
  module Hook; end
  begin
    Class.new(Hook)
  rescue TypeError => e
    puts e.message
  end
end
begin
  H = Class.new(Space::Mixin)
rescue TypeError => e
  puts e.message
end
begin
  Class.new(Comparable)
rescue TypeError => e
  puts e.message
end

# a class with a module of its own named Base reaches the top-level class by ::
class Holder
  module Base; end
  K = Class.new(::Base)
end
p Holder::K.superclass
p Holder::K.new.hi

# a module reached through the ancestors of the namespace the call is written
# in comes before the top-level class of that name: through an include, and
# through a superclass
module Mixin
  module Parent; end
end
class Parent; end
module Includer
  include Mixin
  begin
    Class.new(Parent)
  rescue TypeError => e
    puts e.message
  end
end
class Holder2
  module Parent; end
end
class Derived < Holder2
  begin
    Class.new(Parent)
  rescue TypeError => e
    puts e.message
  end
end
