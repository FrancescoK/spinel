# Flag-only: without the flag (as on master) a change through synchronize's answer or a Hash pair's value misses the String.
# Calls the share facts now follow instead of joining UNKNOWN (#6765): a
# computed send on an Integer or a Symbol, a class body's declarations,
# Mutex#synchronize, a reader of an ivar that holds no String, and a Hash's
# desugared pair enumeration. Each still answers as CRuby where a String is
# changed through another name.
class Box
  include Comparable
  attr_reader :n, :label
  private def secret = 1
  def initialize(label) = (@n = 3; @label = label)
  def <=>(o) = n <=> o.n
end

s = +"abc"
name = [:to_s, :succ][ARGV.size]
t = 7.send(name)
t << "!"
p [t, :sym.send(name)]

b = Box.new(+"lbl")
p b.n + 1
l = b.label
l << "?"
p b.label

m = Mutex.new
u = m.synchronize { s }
u << "~"
p s

h = {"a" => +"x", "b" => +"y"}
vs = h.each_with_object([]) { |(_k, v), acc| acc << v }
vs[0] << "#"
p h
