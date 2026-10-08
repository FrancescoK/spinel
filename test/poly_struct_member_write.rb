# A Struct held beside another type still stores through []=, including nil,
# and every member writer checks the receiver's frozen state.
# spinel: gc-minor
S = Struct.new(:x)
def report
  yield
rescue FrozenError
  puts "frozen"
end

x = [S.new(1).freeze, 0][0]
report { x[:x] = 2; puts "stored" }
report { x["x"] = 2; puts "stored" }
report { x[0] = 2; puts "stored" }
report { x[-1] = 2; puts "stored" }
report { x.x = 2; puts "stored" }
p x.x

typed = S.new(1).freeze
report { typed[:x] = 2; puts "stored" }
report { typed.x = 2; puts "stored" }

o = [S.new(1), 0][0]
p(o[:x] = 2); p o.x
p(o["x"] = 3); p o.x
p(o[0] = 4); p o.x
p(o[-1] = 5); p o.x
p(o.x = 6); p o.x

T = Struct.new(:text)
s = [T.new("value"), 0][0]
p(s[:text] = (ARGV.empty? ? nil : "value")); p s.text
s.text = "again"
p(s["text"] = nil); p s.text
s.text = "again"
p(s[0] = nil); p s.text
[:text, "text", 0, -1].each do |key|
  s.text = "again"
  p(s[key] = nil); p s.text
end

# Numeric members store nil in their own representations.
p(o[:x] = nil); p o.x
F = Struct.new(:number)
f = [F.new(1.5), 0][0]
p(f[:number] = nil); p f.number
p(f["number"] = 2.5); p f.number
p(f[0] = nil); p f.number

# Invalid keys still raise, and the other receiver arms still store.
begin
  o[:missing] = 1
rescue NameError
  puts "name"
end
begin
  o[1] = 1
rescue IndexError
  puts "index"
end
a = [[1], 0][0]
p(a[0] = 7); p a
h = [{ x: 1 }, 0][0]
p(h[:x] = 8); p h

# The receiver, key and value run once, in that order, before frozen checks.
def mark(value, label)
  puts label
  value
end
p(mark(o, "receiver")[mark(:x, "key")] = mark(9, "value"))
p o.x
report { mark(x, "receiver")[mark(:x, "key")] = mark(10, "value") }
s[:text] = String.new("fresh")
p s.text
