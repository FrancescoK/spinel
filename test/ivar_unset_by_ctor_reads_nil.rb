# An ivar no constructor assigns is nil until a method writes it, also when
# every write stores a bool, a Symbol, a Class, a Rational or a Complex.

class Box
  def set(x) = @v = x
  def report = (p [@v.nil?, @v]; puts(@v ? "t" : "f"))
end
b = Box.new
b.report
b.set(false)
b.report
b.set(true)
b.report

class Tag
  def set(x) = @v = x
  def report
    p [@v.nil?, @v, @v.to_s, @v.inspect, @v == nil]
    puts "unset" if @v.nil?
    x = @v
    p x
  end
end
t = Tag.new
t.report
t.set(:a)
t.report

class Kind
  def set(x) = @v = x
  def report = p([@v.nil?, @v, @v.to_s, @v == nil, @v.class])
end
k = Kind.new
k.report
k.set(String)
k.report

class Ratio
  def set(x) = @v = x
  def report = p([@v.nil?, @v])
end
r = Ratio.new
r.report
r.set(1r)
r.report

class Cplx
  def set(x) = @v = x
  def report = p([@v.nil?, @v])
end
cx = Cplx.new
cx.report
cx.set(Complex(1, 2))
cx.report

# A bool written by a helper initialize calls is assigned on a fresh instance.
class Helper
  def initialize = reset
  def reset = (@done = false)
  def done? = @done
  def finish = (@done = true)
end
h = Helper.new
p h.done?
h.finish
p h.done?

# An inherited reader of a slot one subclass's initialize assigns and another
# subclass leaves unset.
class Base
  def show = p([@flag.nil?, @flag])
end
class Child < Base
  def initialize = @flag = true
end
class Bare < Base
  def set = @flag = false
end
Child.new.show
bare = Bare.new
bare.show
bare.set
bare.show

# A module method writing the slot of its includer.
module Mark
  def mark = @mark = :on
  def marked = [@mark.nil?, @mark]
end
class Doc
  include Mark
end
d = Doc.new
p d.marked
d.mark
p d.marked

# Accessors.
class Reader
  attr_accessor :state
  def kind = @kind
  def kind!(k) = @kind = k
end
rd = Reader.new
p rd.state, rd.kind
rd.state = true
rd.kind!(Integer)
p rd.state, rd.kind

# A memo written through ||=.
class Memo
  def ready = (@ready ||= compute)
  def compute = true
  def peek = @ready
end
m = Memo.new
p m.peek
p m.ready
p m.peek
