# `x &&= v` and `x ||= v` on an Integer or Float local whose value is nil,
# or a local only nil is written to, leave the local nil as `x = v` does.
z = nil
y = 2
y &&= z
p y, y.nil?
y2 = 2
y2 = 3 if ARGV.size > 4
y2 &&= nil
p y2
w = 1.5
w &&= nil
p w, [w]
q = nil
q = 1 if ARGV.empty?
r = nil
q &&= r
p q
k = nil
k = 3 if ARGV.size > 4
k ||= nil
p k, k.nil?
v = 4
u = (v &&= z)
p u, v
s = 5
pr = proc { s }
s &&= z
p s, pr.call
