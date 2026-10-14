# spinel: share
# spinel: gc-minor
# pop and shift hand back the String itself.
s = +"s"
q = [s, +"u", +"v"]
x = q.shift
y = q.pop
p x.equal?(s), y.equal?(q[0]), q.size
x << "X"
y << "Y"
p s, q, y
z = q.pop
z << "Z"
p z, q, q.pop, q.shift, q.empty?
w = [s]
w << s
w.pop << "!"
p w, s
