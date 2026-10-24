# A method whose C name is a helper every class may be given: a class has
# sp_<Class>__gc_scan for the collector, and an Array or Hash subclass also
# sp_<Class>__alloc and sp_<Class>__dup, while `def _gc_scan` in class A
# is sp_A__gc_scan too -- "conflicting types" and the program did not
# compile. The method takes another name.
class A
  def initialize = @a = [1]
  def _gc_scan = "A#_gc_scan #{@a.size}"
end
class L < Array
  def _alloc(n)
    push(n)
    size
  end
  def _dup(n)
    push(n)
    sum
  end
end
class H < Hash
  def _alloc(k)
    self[k] = 1
    size
  end
end
p A.new._gc_scan
l = L.new
p l._alloc(2), l._dup(3), l.dup.class, l.dup
h = H.new
p h._alloc(:a), h.dup.class
