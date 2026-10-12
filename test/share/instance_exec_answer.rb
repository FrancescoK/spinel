# instance_exec's value is its block's: a String the block answers is that
# String itself, on a receiver with instance variables, on one without
# (Object.new, nil, an Integer) and on one of several classes.
class K
  def initialize = @a = 1
  def pre = "K"
end
class J
  def pre = "J"
end
s = +"ab"
s << "c"
[Object.new, nil, K.new, 5].each_with_index do |o, i|
  r = o.instance_exec(s) { |v| v }
  r << i.to_s
  p r.equal?(s)
  r2 = o.instance_exec("lit") { |v| (+v) << "!" }
  p r2, r2.frozen?
end
p s
o = ARGV.size == 0 ? J.new : K.new
r = o.instance_exec(s) { |v| v << pre; v }
r << "!"
p s, r.equal?(s)
r3 = o.instance_eval { pre.dup << "?" }
p r3
r5 = 5.instance_exec(s) { |v| v }
r5 << "5"
p s, r5.equal?(s)
# an instance variable the block reads is the receiver's
class N
  def initialize(n) = @name = n
  def name = @name
end
class M
  def initialize(n) = @name = n
end
class Q
  def initialize = @name = "Q"
  def run(k) = k.instance_exec { @name }
end
t = +"nm"
t << "e"
n = N.new(t)
a1 = n.instance_exec { @name }
a1 << "1"
a2 = n.instance_eval { @name }
a2 << "2"
a3 = n.instance_exec { x = @name; x }
a3 << "3"
a4 = n.instance_exec { @name.itself }
a4 << "4"
p t, n.name.equal?(t)
nm = ARGV.size == 0 ? M.new(t) : N.new(t)
a5 = nm.instance_exec { @name }
a5 << "5"
a6 = Q.new.run(N.new(t))
a6 << "6"
p t, a5.equal?(t), a6.equal?(t)
# a method answering the splice hands its caller the String too
def exec_in(y) = Object.new.instance_exec(y) { |w| w << "?" }
k = exec_in(t)
k << "!"
p t, k.equal?(t)
# nested splices: each block's instance variable is its own receiver's
u1 = +"uu"
u2 = +"vv"
n1 = N.new(u1).instance_exec { M.new(u2).instance_exec { @name } }
n2 = N.new(u1).instance_exec { x = M.new(u2).instance_exec { @name }; @name }
u1 << "!"
u2 << "?"
p n1, n1.equal?(u2), n2, n2.equal?(u1)
