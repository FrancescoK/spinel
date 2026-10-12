# A call on a boxed receiver whose methods answer a String in different
# ways -- one may answer its own field's String, another always a new one --
# kept by a container (an Array literal, `map`'s block, a Hash literal, `<<`)
# is each method's own answer: the field's String itself, changed in place
# through the element, or a new String that no other name holds.
class A
  def initialize(x) = @x = x
  def get(k) = k == 0 ? @x : @x + "a"
end
class B
  def initialize(x) = @x = x
  def get(k) = @x + "b"
end
src = "s".dup
objs = [A.new(src), B.new(src)]
arr = objs.map { |o| o.get(1) }
arr2 = [objs[0].get(1), objs[1].get(1)]
arr[0] << "#"; arr2[1] << "!"
p arr, arr2, src

arr = objs.map { |o| o.get(0) }
arr2 = [objs[0].get(0), objs[1].get(0)]
arr[0] << "#"; arr2[1] << "!"; arr[1] << "?"
p arr, arr2, src
h = { k: objs[0].get(0) }
h[:k] << "%"
p src

# a later element that changes the String runs after the call
arr3 = [objs[0].get(0), (src << "z"; 1)]
arr3[0] << "@"
p src, arr3
q = []
objs.each { |o| q << o.get(0) }
q[0] << "1"; q[1] << "2"
p q, src

# an alias arm beside a method answering a memoized field
class E2; def initialize(x) = @x = x; def text = @x; alias get text; end
class F2; def get = @y ||= +"fy"; end
src2 = +"s"
objs2 = [E2.new(src2), F2.new]
got = objs2.map { |q| q.get }
got[0] << "0"; got[1] << "1"
p got, src2, objs2[1].get

# the local later holds objects of a class with no such method
class E9; def initialize(x) = @x = x; def get(k) = k == 0 ? @x : @x + "e"; end
class F9; def initialize(x) = @x = x; def get(k) = @x + "f"; end
class P9; attr_accessor :a; end
src9 = "s".dup
objs9 = [E9.new(src9), F9.new(src9)]
got9 = objs9.map { |q| q.get(0) }
got9[0] << "#"
p got9, src9
objs9 = [P9.new]
p objs9.size

# an identity compare of a boxed call whose one target publishes the
# handle an ivar keeps (the dispatch boxes the arm's handle)
class A10; attr_accessor :v; end
class B10
  def v=(x); @v = x; @w = x; end
  def v = @v
  def w = @w
end
objs10 = [A10.new, B10.new]
k10 = +"k"
objs10.each { |o| o.v = k10 }
objs10[1].w << "W"
p k10, objs10[1].w.equal?(k10)
