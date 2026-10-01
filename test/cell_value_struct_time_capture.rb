# A local a proc captures lives in a heap cell. Range, Rational, Complex and a
# class each ride a cell of their own C struct, but Time, Process::Tms and a
# String range -- the other by-value builtins -- were refused as a
# "non-integer capture", at the top level with no FILE:LINE. A user class
# held by value had no cell either. The String range's cell marks its two
# endpoint strings.

t = Time.at(0)
pr = proc { t.to_i }
p pr.call

l = -> { t.to_i + 1 }
p l.call

def keep(&b) = (@kept = b)
u = Time.at(7)
keep { u.to_i }
p @kept.call

w = Time.at(1)
setw = proc { w = Time.at(9) }
setw.call
p w.to_i

def mk(t) = proc { t.to_i }
p mk(Time.at(11)).call

def mk2
  t = Time.at(12)
  -> { t.to_i }
end
p mk2.call

2.times do |n|
  x = Time.at(n)
  q = proc { x = Time.at(n + 20); nil }
  q.call
  p x.to_i
end

tms = Process.times
p proc { tms.utime.class }.call

r = ("a" + "1")..("a" + "3")
rd = proc { r.to_a }
setr = proc { r = ("x" + "1")..("x" + "3") }
GC.start
p rd.call
setr.call
GC.start
p r.to_a
p rd.call

class V
  attr_reader :a
  def initialize(a) = (@a = a)
end
v = V.new("s" * 3)
pv = proc { v.a }
GC.start
p pv.call
setv = -> { v = V.new("t" * 2) }
setv.call
p v.a

# a block on a receiver typed poly only by the late widenings -- a parameter
# every caller passes nil -- is lifted by the last capture pass, after the
# value-type detection has run: the instance it captures still needs a cell
class W
  def initialize(a) = (@a = a)
  def a = @a
end
def lift(r)
  w = W.new(7)
  begin
    p(r.map { w.a })
  rescue NoMethodError
    p :no_map
  end
  0
end
p lift(nil)
