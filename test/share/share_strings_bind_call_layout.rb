# spinel: share
# spinel: gc-minor
# bind_call hands the arguments after its receiver to the method's parameters
# by the method's own layout: an optional parameter before a required one, a
# post parameter behind a rest and a keyword take the argument the call gives
# them, so a String handed to a boxed one is the handle that parameter holds.
class Meth
  def initialize(s) = @s = s
  def mget = @s
  def mset(a = nil, v) = (@s = v)
  def mpost(a, *r, v) = (@s = v)
  def mkw(v:) = (@s = v)
  def mmix(a, v, k: 0) = (@s = v)
end
Meth.new(nil)
me = Meth.new(5)
# each parameter also takes an Integer, so it is boxed
me.mset(1, 2)
me.mpost(1, 2)
me.mkw(v: 3)
me.mmix(1, 2, k: 3)

Meth.instance_method(:mset).bind_call(me, +"bc")
m = me.mget
m << "*"
p me.mget

Meth.instance_method(:mset).bind_call(me, 1, +"both")
m = me.mget
m << "="
p me.mget

Meth.instance_method(:mpost).bind_call(me, 1, +"post")
m = me.mget
m << "+"
p me.mget

Meth.instance_method(:mpost).bind_call(me, 1, 2, 3, +"posts")
m = me.mget
m << "~"
p me.mget

Meth.instance_method(:mkw).bind_call(me, v: +"kw")
m = me.mget
m << "-"
p me.mget

Meth.instance_method(:mmix).bind_call(me, 1, +"mix", k: 4)
m = me.mget
m << "%"
p me.mget

# a Method handed in as an argument: no one method names the call's target, and
# every method the program takes with `method` counts, each by its own layout
def call_with(m, v) = m.call(v)
def call_with2(m, v) = m.call(1, v)
def call_with_kw(m, v) = m.call(v: v)
call_with(me.method(:mset), +"arg")
m = me.mget
m << "?"
p me.mget
call_with2(me.method(:mpost), +"arg2")
m = me.mget
m << "!"
p me.mget
call_with_kw(me.method(:mkw), +"argkw")
m = me.mget
m << "@"
p me.mget
