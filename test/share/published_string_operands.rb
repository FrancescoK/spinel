# A method's answer that is a String the program keeps, and changes in place,
# is that String in an Array literal, among a builtin's arguments, as an
# operand of `+` and as an interpolation's part, even when a later element,
# argument, operand or part changes it again before anything reads them:
# each reads the String as it is then, as in CRuby.
class Parent
  attr_reader :name
  def initialize = (@name = +"name")
  def change
    s = name
    s << "!"
    s
  end
end
x = Parent.new
p [x.change, x.change, x.name]
y = Parent.new
p y.change, y.change

def ch(t) = (t << "!"; t)
u = +"u"
p [ch(u), ch(u)]
v = +"v"
p ch(v), ch(v)
w = +"w"
printf("%s %s\n", ch(w), ch(w))
s = +"a"
p [s, (s << "b"; s)]

# interpolation, puts, + and join of the same operands
z = Parent.new
p "#{z.change} #{z.change}"
puts "#{z.change}/#{z.change}"
p z.change + z.change
p [z.change, z.change].join(",")
i = +"i"
p "#{ch(i)}#{ch(i)}"
puts ch(i), ch(i)
p ch(i) + ch(i)
p [ch(i), ch(i)].join("-")
puts "<#{ch(i)}#{1 + 1}#{ch(i)}>"
j = +"j"
t = +""
t << "#{ch(j)}:#{ch(j)}"
p t
p ch(j) + "-" + ch(j)

# a literal of mixed elements and a Hash literal of the same operands
k = +"k"
p [ch(k), 1, ch(k)]
l = +"l"
p({ a: ch(l), b: ch(l) })
