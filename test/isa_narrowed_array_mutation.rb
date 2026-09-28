# Mutating an element through a read narrowed by `is_a?(Array)` must reach
# the element itself, not a copy of it.

x = [[1], +"s"]
x.each { |o| o.push(5) if o.is_a?(Array) }
p x

y = [[1], +"s"]
y.each { |o| o.insert(0, 9) if o.is_a?(Array) }
p y

z = [[3, 1], "s"]
z.each { |o| o << 2 if o.is_a?(Array) }
z.each { |o| o[0] = 7 if o.is_a?(Array) }
z.each { |o| o[1] += 10 if o.is_a?(Array) }
z.each { |o| o.sort! if o.is_a?(Array) }
z.each { |o| o.map! { |e| e * 2 } if o.is_a?(Array) }
z.each { |o| o.concat([8]) if o.is_a?(Array) }
p z

w = [[3, 1], "s"]
w.each { |o| o.clear if o.is_a?(Array) }
p w

v = [[3, 1], "s"]
v.each { |o| o.is_a?(Array) && o.push(4) }
v.each { |o| next unless o.is_a?(Array); o.push(6) }
v.each { |o| r = (o.push(7) if o.is_a?(Array)); p r }
p v

def add_nine(a) = a.push(9)
u = [[3, 1], "s"]
u.each { |o| add_nine(o) if o.is_a?(Array) }
u.each { |o| if o.is_a?(Array); k = o; k.push(4); end }
u.each { |o| p o.equal?(u[0]) if o.is_a?(Array) }
p u

t = [["a"], 1]
t.each { |o| o.map!(&:upcase) if o.is_a?(Array) }
p t

f = [[1.5], 1]
f.each { |o| o.push(2.5) if o.is_a?(Array) }
p f

h = {a: [1], b: "s"}
h.each_value { |o| o.concat([2, 3]) if o.is_a?(Array) }
p h

s = [[1], 2]
e = s[0]
e.push(5) if e.is_a?(Array)
p s

hh = [{a: 1}, 2]
hh.each { |o| o[:b] = 2 if o.is_a?(Hash) }
p hh

# A method that hands the receiver on (a block argument, its own result)
# must hand on the element, not a copy of it.
r = [[3, 1], "s"]
r.each { |o| o.tap { |a| a.push(1) } if o.is_a?(Array) }
r.each { |o| o.then { |a| a.push(2) } if o.is_a?(Array) }
r.each { |o| o.yield_self { |a| a.push(3) } if o.is_a?(Array) }
r.each { |o| o.itself.push(4) if o.is_a?(Array) }
r.each { |o| p o.itself.equal?(r[0]) if o.is_a?(Array) }
r.each { |o| o.send(:push, 5) if o.is_a?(Array) }
r.each { |o| o.public_send(:push, 6) if o.is_a?(Array) }
r.each { |o| o.dup.push(0) if o.is_a?(Array) }
r.each { |o| o.select { |e| e > 1 }.push(0) if o.is_a?(Array) }
r.each { |o| p [o.size, o.first, o.sum, o.include?(3), o.join("-"), o.map { |e| e + 1 }] if o.is_a?(Array) }
p r
