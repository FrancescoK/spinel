# A call on a boxed receiver binds the parameters of the methods of the
# classes the receiver can hold, not of every class with the name (#8530):
# Seq#output keeps Integer parameters although History#output and
# Empty#output take a String through a boxed receiver.
class Seq
  def output(col, shift) = (col * 8) + shift
end

class History
  def output(sid, mix) = "#{sid}:#{mix}"
end

class Empty
  def output(_sid, _mix) = "-"
end

s = Seq.new
t = 0
1000.times { |i| t += s.output(i, 3) }
p t

# an Array element
views = [History.new, Empty.new]
p views[0].output("a", 1)
p views[1].output("b", 2)

# a method parameter given two classes
def show(v, tag) = v.output(tag, 9)
p show(History.new, "c")
p show(Empty.new, "d")

# an ivar written either class
class Holder
  def initialize(full)
    @v = full ? History.new : Empty.new
  end

  def run(tag) = @v.output(tag, 4)
end
p Holder.new(true).run("e")
p Holder.new(false).run("f")

# a Hash value
h = { h: History.new, e: Empty.new }
p h[:h].output("g", 5)

# a safe navigation on an element that can be nil
pair = [History.new, nil]
p pair[0]&.output("i", 6)
p pair[1]&.output("j", 7)

# a method's value
def pick(flag) = flag ? History.new : Empty.new
p pick(true).output("k", 8)

# a Struct holding either class, read back through its member
Cell = Struct.new(:view)
cells = [Cell.new(History.new), Cell.new(Empty.new)]
p cells.map { |c| c.view.output("l", 1) }

# a value stored through a user-defined container method
class Bag
  def initialize = @items = []
  def add(x) = @items << x
  def first = @items[0]
end
bag = Bag.new
bag.add(Empty.new)
bag.add(History.new)
p bag.first.output("m", 2)

# a class whose instances never meet a String keeps its Integer answers
p s.output(5, 1) + s.output(2, 2)
