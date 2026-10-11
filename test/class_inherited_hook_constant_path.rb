# A class fires its superclass's inherited hook once, the first time it is
# defined. Which definitions are the same class is decided by the whole path
# the header writes: `class A::Foo` and `class B::Foo` are two classes, and
# `module C; class Bar` reopened as `class C::Bar` is one. A path's first
# segment is looked up from the scopes around the header, as a constant
# would be: `module K; class K::Baz` is K::Baz, not K::K::Baz, and a
# constant holding a module stands for it: `class KAlias::Quux` is K::Quux.

class Base
  def self.inherited(sub)
    puts "inherited: #{sub}"
  end
end

module C
  class Bar < Base; end
end
class C::Bar < Base; end

module D
  class E; end
end
module D
  class E::F < Base; end
end
class D::E::F < Base; end

class ::G < Base; end
module C
  class ::G < Base; end
end

module K; end
class K::Baz < Base; end
module K
  class K::Baz < Base; end
end
module M
  module N; end
  class N::Qux < Base; end
end
class M::N::Qux < Base; end
module M
  class N::Qux < Base; end
end

class Counted
  @count = 0
  def self.count = @count
  def self.inherited(sub)
    @count += 1
  end
end
module A; end
module B; end
KAlias = K
class KAlias::Quux < Counted; end
class K::Quux < Counted; end
module M
  Inner = K
  class Inner::Corge < Counted; end
end
class K::Corge < Counted; end

class A::Foo < Counted; end
class B::Foo < Counted; end
puts "Counted subclasses: #{Counted.count}"
