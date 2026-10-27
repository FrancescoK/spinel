# A file's BEGIN blocks run before its other statements, so an alias in a
# class body captures a def that a BEGIN block later in the file makes, as
# in CRuby: the alias keeps that body after the class body redefines the
# name. With `alias`, with `alias_method` and for a class method's alias in
# a `class << self` body.
class C
  alias old f
  def f = 2
end

class D
  alias_method :old, :f
  def f = 20
end

class E
  class << self
    alias old f
  end
  def self.f = 200
end

BEGIN {
  class C
    def f = 1
  end
  class D
    def f = 10
  end
  class E
    def self.f = 100
  end
}

p C.new.old
p C.new.f
p D.new.old
p D.new.f
p E.old
p E.f
