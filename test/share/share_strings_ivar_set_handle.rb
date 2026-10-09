# spinel: gc-minor
# instance_variable_set into an ivar the share rule makes a String handle
# stores the value's handle: the variable and the slot are one String, as
# in CRuby. Typed and boxed receivers, an ivar only instance_variable_set
# writes, a frozen receiver, and the call's value dropped or used.
class Plain
  def text = @text
end
class Seeded
  def initialize = (@text = +"seed")
  def text = @text
  def append(x) = (@text << x)
  def put(v) = instance_variable_set(:@text, v)
end
class Boxed
  def initialize = (@text = 5)
  def text = @text
end

# an ivar nothing but instance_variable_set writes
o = Plain.new
s = +"abc"
p o.instance_variable_defined?(:@text), o.instance_variables
o.instance_variable_set(:@text, s)
s << "!"
o.text << "?"
p o.text, s
p o.instance_variable_defined?(:@text), o.instance_variables

# the call's value, dropped above, used here
u = Plain.new
t = +"x"
p u.instance_variable_set(:@text, t)
t << "y"
p u.text
puts(u.instance_variable_set(:@text, "q" + "r"))
u.text << "s"
p u.text

# an ivar initialize sets, and a write through a method of the class
q = Seeded.new
w = +"w"
puts(q.instance_variable_set(:@text, w))
w << "1"
q.append("2")
p q.text, w
z = +"z"
q.put(z)
z << "3"
p q.text
old = q.text
q.put(+"new")
old << "4"
p q.text, old

# a frozen receiver raises and keeps its slot; a sibling is written
f = Seeded.new
f.freeze
begin
  f.instance_variable_set(:@text, w)
rescue FrozenError => e
  p e.class
end
w << "5"
p f.text
g = Seeded.new
v = +"v"
puts(g.instance_variable_set(:@text, v))
v << "6"
p g.text

# a boxed receiver: each class has its own kind of slot
objs = [Seeded.new, Boxed.new, Plain.new, 7, f]
m = +"m"
objs[0, 3].each { |r| r.instance_variable_set(:@text, m) }
m << "1"
p objs[0].text, objs[1].text, objs[2].text
objs[0].append("2")
p m
p objs[2].instance_variable_defined?(:@text)
r = objs[0].instance_variable_set(:@text, m)
m << "3"
p r, objs[0].text
objs[3..].each do |x|
  begin
    x.instance_variable_set(:@text, m)
  rescue FrozenError => e
    p e.class
  end
end

# a Data instance is frozen
D = Data.define(:a)
begin
  D.new(1).instance_variable_set(:@text, m)
rescue FrozenError => e
  p e.class
end

# a frozen String literal is the handle of its own site: it stays frozen, and
# one site stores one String however often it runs
def lit_ids(o)
  ids = []
  3.times do
    o.instance_variable_set(:@text, "site")
    ids << o.text.object_id
  end
  ids.uniq.size
end
lo = Plain.new
p lit_ids(lo), lo.text, lo.text.frozen?
begin
  lo.text << "x"
rescue FrozenError => e
  p e.class
end
kept = lo.text
lo.instance_variable_set(:@text, "site")
p kept.equal?(lo.text)
lo.instance_variable_set(:@text, "other")
p kept.equal?(lo.text), lo.text
ls = Seeded.new
ls.instance_variable_set(:@text, "lit")
alias_of = ls.text
begin
  ls.append("!")
rescue FrozenError => e
  p e.class
end
ls.instance_variable_set(:@text, +"mutable")
ls.append("!")
p ls.text, alias_of
fr = Seeded.new
fr.instance_variable_set(:@text, "lit")
p fr.text.equal?(alias_of)
f.instance_variable_set(:@text, "lit") rescue p $!.class
p f.text
