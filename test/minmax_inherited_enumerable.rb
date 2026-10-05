# minmax on a class that has Enumerable through a module it includes or
# through its superclass, as on one that includes it itself; a class whose
# superclass has only a bare #each still has no minmax.
module M
  include Enumerable
end
class A
  include M
  def each
    yield 3
    yield 1
  end
end
class B < A; end
class C
  include Enumerable
  def each
    yield 2
    yield 5
  end
end
class D < C; end
p A.new.minmax
p D.new.minmax
class Bare
  def each
    yield 1
  end
end
class BareSub < Bare; end
begin
  BareSub.new.minmax
rescue NoMethodError => e
  puts e.message
end
p B.new.minmax
