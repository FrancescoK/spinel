# `class Foo < Foo` reads its superclass in the scope around the header,
# before the new constant exists: the nearest Foo seen from there, not the
# class being defined.
class Foo
  def base = :top
end
module A
  class Foo < Foo
    def own = :own
  end
  def self.mk = Foo.new
end
p A::Foo.new.base, A::Foo.new.own, A::Foo.superclass, A::Foo.ancestors.take(2)
p A.mk.class, Foo.new.base

# an enclosing module's Foo comes first
module B
  class Foo
    def base = :b
  end
  module C
    class Foo < Foo; end
  end
  module D; end
  class D::Foo < Foo; end
end
p B::C::Foo.superclass, B::C::Foo.new.base, B::D::Foo.superclass, B::D::Foo.new.base

# and an included module's Foo
module M
  class Foo
    def base = :m
  end
end
module E
  include M
  class Foo < Foo; end
end
p E::Foo.superclass, E::Foo.new.base

# a later reopening of the class does not change what the first header read
module G
  class Foo < Foo; end
end
module G
  class Foo
    def extra = 1
  end
  class Foo; end
end
p G::Foo.superclass, G::Foo.new.base, G::Foo.new.extra
