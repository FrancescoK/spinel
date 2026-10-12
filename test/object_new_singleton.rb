# Singleton methods on an Object.new: def obj.m, define_singleton_method
# and class << obj, held in a local, a constant or an instance variable.
# The object still answers as an Object.
o = Object.new
begin
  o.hi
rescue NoMethodError => e
  puts "before the def: #{e.class}"
end
def o.hi = "hi"
def o.=~(x) = x == 5
def o.to_str = "str"
p o.hi, (o =~ 5), (o =~ 4)
p o.class, o.class == Object, o.class.name, o.class.superclass
p o.instance_of?(Object), o.is_a?(Object), Object === o
p o.singleton_methods.sort
p o.respond_to?(:hi), o.respond_to?(:nope)
p o.to_s.match?(/\A#<Object:0x\h+>\z/), o.inspect.match?(/\A#<Object:0x\h+>\z/)
p "a#{o}b".match?(/\Aa#<Object:0x\h+>b\z/)
p o == o, o.equal?(o), o.frozen?
p "x" + o
case o
when Object then puts "case Object"
end
p o.method(:hi).call

# a copy drops the singleton methods
q = Object.new
def q.get = 7
d = q.dup
p q.get, d.class, d.respond_to?(:get), d.instance_of?(Object)

r = Object.new
r.define_singleton_method(:dsm) { 41 + 1 }
p r.dsm

s = Object.new
class << s
  def a = :a
  def b = a.to_s * 2
end
p s.a, s.b, s.class

# an Object.new's extend stays refused; a user object's works
module Greet
  def greet = "hello from #{self.class}"
end
class Box; end
t = Box.new
t.extend(Greet)
p t.greet, t.is_a?(Greet)

# a constant: its own #=== is what case/when and grep call
PATTERN = Object.new
def PATTERN.===(x) = x.is_a?(Integer) && x > 10
p [5, 20].map { |v| PATTERN === v }
p [3, 30, 7, 70].grep(PATTERN)
case 25
when PATTERN then puts "case PATTERN"
end

class Holder
  def initialize
    @m = Object.new
    def @m.call(x) = x * 3
  end
  def run = @m.call(4)
end
p Holder.new.run

# a user class's singleton answers as that class too
class Plain; end
w = Plain.new
def w.extra = 1
p w.extra, w.class == Plain, w.class.name

# a plain Object.new elsewhere is unaffected
u = Object.new
p u.respond_to?(:hi), u.class, u.instance_of?(Object)
h = { o => 1 }
p h[o]
p [o, 1].map(&:class)

# respond_to? and Marshal read the object as it stands at each point
v = Object.new
p v.respond_to?(:late), Marshal.dump(v).bytesize
def v.late = 1
p v.respond_to?(:late)
begin
  Marshal.dump(v)
rescue TypeError => e
  puts "TypeError: #{e.message}"
end

# a copy keeps the instance variables
x = Object.new
x.instance_variable_set(:@n, 5)
def x.n = @n
y = x.dup
p y.instance_variable_get(:@n), y.respond_to?(:n)

# define_singleton_method answers the name it defined
z = Object.new
p z.define_singleton_method(:zz) { 1 }

# read back out of a mixed array
any = [o, 1].first
p any.class, any.class.new.respond_to?(:hi)

# a String name, a sentinel set up in a module body, and a def in value position
named = Object.new
p named.define_singleton_method("named") { :n }, named.named
module Undefined
  VALUE = Object.new
  def VALUE.inspect = "Undefined"
end
p Undefined::VALUE
early = Object.new
before = early.inspect.match?(/\A#<Object:0x\h+>\z/)
def early.inspect = "late"
p before, early.inspect
rv = (def early.ping = :pong)
p rv, early.ping

# Object's own == until the def runs, and in a copy
eq = Object.new
p eq == eq
def eq.==(other) = false
cp = eq.dup
p eq == eq, cp == cp, cp.singleton_methods, eq.singleton_methods

# a frozen object takes no singleton method
fr = Object.new
fr.freeze
begin
  def fr.x = 1
rescue FrozenError => e
  puts e.message.sub(/0x\h+/, "X")
end
p fr.respond_to?(:x)

# a proc that captures the binding sees the method once the def has run
cap = Object.new
seen = proc { cap.respond_to?(:late2) }
p seen.call
def cap.late2 = 2
p seen.call, cap.late2

# a constant answers respond_to? as the object stands
CO = Object.new
p CO.respond_to?(:k)
def CO.k = 1
p CO.respond_to?(:k)

# a user object boxed before its def keeps its class's methods
class Handler
  def name = "h"
end
hd = Handler.new
items = [hd, "s"]
def hd.extra = 1 if ARGV.include?("x")
items.each { |it| p it.name if it.is_a?(Handler) }
p items.include?(hd), items.index(hd)

# Object's own answers before the def, for === and nil? too
ce = Object.new
p (case 5 when ce then :hit else :miss end), ce.nil?
def ce.===(x) = true
def ce.nil? = true
p (case 5 when ce then :hit else :miss end), ce.nil?

# an empty class << on a frozen object defines nothing
fe = Object.new
fe.freeze
class << fe
end
p fe.frozen?

# a String the class's own reader hands out is still its slot before the def
class Buf
  def initialize = @s = +"ab"
  def to_s = @s
end
bf = Buf.new
bs = bf.to_s
bs << "e"
def bf.to_s = @s if ARGV.size > 5
p bf.to_s

# read back out of an Array, a copy has no singleton methods
bq = Object.new
def bq.got = 7
bd = bq.dup
p [bd, 1][0].respond_to?(:got), [bq, 1][0].respond_to?(:got)

# FrozenError names the class and the object's own inspect
class Pt
  def initialize = @x = 1
end
pf = Pt.new
pf.freeze
begin
  def pf.y = 2
rescue FrozenError => e
  puts e.message.sub(/0x\h+/, "X")
end
sf = Object.new
def sf.inspect = "sf"
sf.freeze
begin
  def sf.late = 1
rescue FrozenError => e
  puts e.message
end

# a Hash subclass's object is named by its own inspect
class Rg < Hash; end
rg = Rg.new
rg[1] = 2
rg.freeze
begin
  def rg.x = 1
rescue FrozenError => e
  puts e.message
  p e.receiver.class, e.receiver.equal?(rg)
end
