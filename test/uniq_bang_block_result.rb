# Array#uniq! with a block answers the receiver when it removed something and
# nil when it removed nothing, over an Integer, Float, String or poly Array,
# one holding a nil element among them.
a = [3, 3, 1]
p a.uniq! { |v| v }
p a
p a.uniq! { |v| v }
p a

b = [3, 3, 1]
b[4] = 1
p b.uniq! { |v| v }
p b

c = [3, 1]
c[4] = 1
x = c.uniq! { |v| v }
p x

f = [1.5, 1.5]
f[3] = 2.5
p f.uniq! { |v| v }
p f.uniq! { |v| v }

s = ["a", "B", "b"]
p s.uniq! { |v| v.downcase }
p s.uniq! { |v| v.downcase }

m = [1, "1", 2]
p m.uniq! { |v| v.to_s }
p m.uniq! { |v| v.to_s }

n = [5, 6, 7]
p n.uniq! { |v| v % 2 }.length
