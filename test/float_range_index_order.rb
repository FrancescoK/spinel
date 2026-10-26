# A Float Range index whose ends run code converts in Ruby's order: once,
# after the operands before it, and only past a `&.` receiver's nil check.

def say(x)
  puts "say #{x}"
  x
end

def at(i)
  puts "at #{i}"
  i
end

a = [10, 20, 30, 40, 50]
p a.values_at(at(0), (say(1.5)..say(2.5)))
p a.values_at(at(4), (say(0.5)..say(1.5)), at(3))
k = 2.0
p a.values_at(k, (say(0.5)..(k = 3.5)), k)
p a.slice(say(0.5)..say(1.5))
p a[say(0.5)..say(1.5)]
p a.slice!(say(0.5)..say(1.5))
p a
a[say(0.5)..say(1.5)] = [7]
p a
a.slice!(say(0.5)..say(1.5))
p a

s = "abcdef"
p s.slice(say(0.5)..say(1.5))
p s[say(0.5)..say(1.5)]

class Holder
  def fill
    @a = [1, 2, 3, 4]
  end

  def run
    p @a&.slice(say(0.5)..say(1.5))
    p @a&.values_at(at(0), (say(0.5)..say(1.5)))
    @a&.slice!(say(0.5)..say(1.5))
    p @a
  end
end

h = Holder.new
h.run
h.fill
h.run
