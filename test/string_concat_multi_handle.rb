# String#concat with several arguments on a String that another name also
# holds (a shared handle): each argument is appended in place, in order, and
# every argument is taken before the first append, so the receiver passed as
# an argument appends as it was. The statement form used to reassign the
# handle's copy and the C did not compile.

b = +"x"
b2 = b
b.concat("y", "z")
p b2
b.concat(67, "D", 69)
p b2
b.concat(b, b)
p b2

def app(s)
  s.concat("p", "q")
  nil
end
c = +"c"
c2 = c
app(c)
p c2

class Log
  def initialize
    @s = +"<"
  end

  def add(a, b)
    @s.concat(a, b)
    @s
  end
end
p Log.new.add("1", "2")

d = +"d"
d2 = d
d.freeze
begin
  d.concat("e", "f")
rescue FrozenError => e
  p e.class
end
p d2

# A boxed argument that is the receiver itself appends the String as it was,
# once per argument; and every argument runs before the frozen check.
s = +"ab"
t = s
x = [s, 1][0]
s.concat(x, x)
p s, t
f = +"fz"
g = f
f.freeze
def mark(v)
  puts "arg #{v}"
  v
end
begin
  g.concat(mark("1"), mark("2"))
rescue FrozenError => e
  puts e.class
end
