# A yield from a block that rides a proc (the receiver may be a user class
# whose reduce takes it) hands on an argument with no type: a call to a
# method nothing defines. Its temp is the slot's Integer, not the boxed raise.

class Ev
  attr_reader :type, :text
  def initialize(t, x) = (@type = t; @text = x)
end

class Tree
  def initialize(a) = @a = a
  def reduce(acc) = @a.each { |e| acc = yield(acc, e) } && acc
end

def each_escape(evs)
  evs.reduce(0) do |depth, (event, expr)|
    yield(expr.text[1], expr.ts, !depth.zero?) if expr.type == :escape
    depth + 1
  end
end

quiet = [[:enter, Ev.new(:lit, "ab")], [:exit, Ev.new(:lit, "cd")]]
loud = [[:enter, Ev.new(:lit, "ab")], [:exit, Ev.new(:escape, "\\d")]]
[quiet, Tree.new(quiet), loud, Tree.new(loud)].each do |evs|
  begin
    p(each_escape(evs) { |ch, i, inside| p [ch, i + 1, inside] })
  rescue NoMethodError => e
    puts "NoMethodError: #{e.name}"
  end
end

# an unresolved super as the argument: it raises NoMethodError when reached
class Walker
  def each_pair(evs)
    evs.reduce(0) do |depth, e|
      yield(super(), e) if e > 1
      depth + 1
    end
  end
end
[[1, 2], Tree.new([1])].each do |evs|
  p(Walker.new.each_pair(evs) { |a, b| p [a + 1, b] })
rescue NoMethodError
  puts "NoMethodError"
end
