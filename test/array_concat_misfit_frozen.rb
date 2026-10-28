# concat and replace with an operand no Array conversion takes: as a
# statement, an Integer into an Integer Array (and a Float, a String into
# their own kinds) gave C that does not build; it is CRuby's TypeError. A
# frozen receiver raises FrozenError first, before any operand converts,
# also for a boxed operand that holds nil.
def try
  yield
rescue => e
  puts e.class
end
a = [1]
try { a.concat(1) }
try { a.concat([2], 3) }
p a
f = [1.5]
try { f.concat(2.5) }
p f
s = ["x"]
try { s.concat("y") }
p s
z = [1].freeze
try { z.concat(1) }
try { z.concat("y") }
try { p z.concat(nil) }
try { z.replace(1) }
try { p z.replace(nil) }
w = [1, "x"].freeze
x = [nil, [2]].first
try { w.concat(x) }
try { p w.concat(x) }
try { w.concat(5) }
class K
  def initialize = (@a = [1].freeze)
  def go = @a.concat(5)
end
try { K.new.go }
d = [1, 2]
d.concat(d, d)
p d
