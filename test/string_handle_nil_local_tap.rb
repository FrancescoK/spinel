# A String local that may be nil becomes the shared handle when a tap/then
# block appends to it (#6535); nil is a NULL handle and must read as nil.
q = nil
q = +"x" if ARGV.size > 5
r = q.tap { |w| w << "!" if w }
p q, r

s = +"y"
s = nil if ARGV.size > 5
s.tap { |w| w << "?" }
p s

t = nil
t = +"t" if ARGV.size > 5
u = t.then { |w| w << "T" if w; w }
p t, u

v = nil
v = +"v" if ARGV.empty?
v.tap { |w| w << "V" }
p v

f = proc { |x| x << "!" }
n = nil
n = +"n" if ARGV.size > 5
f.call(n) if n
p n
