# +s answers s itself when s isn't frozen, and an unfrozen copy when it is.
# The same for a String held in a boxed slot (an Array element, a Hash
# value), where `+` used to answer the value unchanged, frozen or not.

c = String.new("m")
d = +c
d << "n"
p [c, d, c.equal?(d)]

lit = +"lit"
lit << "!"
p lit

g = -"frz"
k = +g
k << "?"
p [g, k, g.frozen?, k.frozen?]

# a String that is appended to through an alias is a shared handle; +
# answers the handle itself, or a new one when it is frozen
m = String.new("m")
m << "x"
m2 = +m
m2 << "n"
p [m, m2, m.equal?(m2)]
f = String.new("q")
f << "r"
f.freeze
g2 = +f
g2 << "s"
p [f, g2, f.frozen?, g2.frozen?]

# boxed
v = [1, "q"][1]
out = +v
out << "1"
[1].each { out << "2" }
p out

h = {}
[1].each { |i| h[i] = "v#{i}" }
o = +(h[1] || "z")
o << "+"
[1].each { o << "b" }
p o

# a boxed element held as a shared handle: `s = +s` on a frozen one
xs = [1, "s"]
b = xs[1]
b = +b
b << "x"
p b

def build(status_lines, status)
  out = +(status_lines[status] || "HTTP/1.1 #{status} Unknown\r\n")
  { "a" => "1", "b" => "2" }.each { |key, val| out << key << ": " << val << "\r\n" }
  out << "\r\n"
  out
end
lines = {}
[[200, "OK"]].each { |code, text| lines[code] = "HTTP/1.1 #{code} #{text}\r\n" }
p build(lines, 200)
p build(lines, 404)

n = [1, 2.5][0]
p(+n)
