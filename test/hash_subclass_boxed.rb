# A Hash subclass instance held in a boxed value (#7449): boxed as its Hash,
# so the runtime's Hash paths take it, while its class is read back off its
# own GC scan function -- case/when, is_a?, instance_of?, class, the poly
# dispatch of its methods. A dup or clone of one, boxed or typed as a base
# class with a subclass's instance behind it, is a copy of the class it
# carries and runs that class's initialize_copy, before clone freezes it.
class Opts < Hash
  attr_accessor :name
  def label = "opts:#{size}"
end
class Sub < Opts
  def label = "sub:#{size}"
end
o = Opts.new; o[:a] = 1; o.name = "n"
s = Sub[x: 1, y: 2]
items = [o, s, {plain: 1}, 3, "str", [1]]
items.each do |it|
  case it
  when Sub then puts "Sub #{it.label}"
  when Opts then puts "Opts #{it.label} #{it.name}"
  when Hash then puts "Hash #{it.size}"
  else puts "other #{it.class}"
  end
end
p items.map(&:class)
p items.map { |i| i.is_a?(Hash) }, items.map { |i| i.instance_of?(Hash) }
p items.map { |i| i.is_a?(Opts) }
box = items[0]
p box[:a], box.keys, box.class, box.size
h = {k: o}
p h[:k].label, h.values.map(&:class)
def take(x) = x.is_a?(Opts) ? x.label : "no"
p take(o), take(s), take({})
p items.select { |i| Hash === i }.size
q = [o, s].map { |x| x.label }
p q
p o.frozen?, o.dup.name, o.clone.frozen?
o2 = o.dup; o2[:b] = 2; p o, o2, o2.class
p "#{o} and #{s}"
puts o
p o.eql?(o.dup), o.hash == o.dup.hash, [o, o.dup].uniq.size
p o.to_a, o.sort_by { |k, v| v }, o.min_by { |k, v| v }
k, v = *o.first
p k, v
p Opts.new.empty?, Sub.new.class, Sub.superclass, Sub.ancestors.take(3)
p o.respond_to?(:label), o.respond_to?(:each_pair), o.respond_to?(:nope)

class Base < Hash
  attr_accessor :tag
  def initialize_copy(o)
    super
    @tag = "copied #{o.tag}"
  end
end
class Leaf < Base
  def initialize_copy(o)
    super
    @tag = "leaf #{@tag}"
  end
end
def dupit(x) = x.dup
b = Base.new; b.tag = "b"; b[:k] = 1
l = Leaf.new; l.tag = "l"; l[:z] = 2
p dupit(b).tag, dupit(l).tag, dupit(l).class, dupit(l)
class Holder
  def initialize(x) = @x = x
  def copy = @x.dup
end
[Holder.new(b), Holder.new(l)].each { |h| c = h.copy; p [c.class, c.tag, c] }
fz = Leaf.new; fz.tag = "f"; fz.freeze
c2 = fz.clone; p c2.frozen?, c2.tag; c3 = fz.dup; p c3.frozen?
sg = Base.new
def sg.hello = "hi #{size}"
sg[:q] = 1
p sg.hello, sg.class

# merge and compact answer a copy of the instance's class, with its ivars,
# also on a boxed instance; select and the others a plain Hash
class Tagged < Hash
  attr_accessor :tag
end
tg = Tagged[a: 1, b: nil]
tg.tag = "t"
bx = [tg, "s"][ARGV.size]
mg = bx.merge(c: 1)
p mg.class, mg, mg.tag
p bx.merge({a: 5}) { |k, l, r| l + r }.class, bx.merge({c: 2}, {d: 3}).class
cp = bx.compact
p cp.class, cp, cp.tag, bx.merge(z: 0).merge(w: 1).tag
p bx.select { true }.class, bx.reject { false }.class, bx.class, bx
pl = [{q: 1}, "s"][ARGV.size]
p pl.merge(r: 2).class, pl.compact.class

