# Array.new given an empty Array literal is a copy of it, an empty Array --
# not Array.new(size), which raised TypeError (the literal had no element
# kind yet to say it is an Array). An Array subclass's new takes the same
# path (activesupport's ArrayInquirer.new([])).
a = Array.new([])
p a, a.size
a << 1
p a

class Tags < Array
  def second = self[1]
end
t = Tags.new([])
p t.size, t.empty?
t << :x << :y
p t.second, t.class
