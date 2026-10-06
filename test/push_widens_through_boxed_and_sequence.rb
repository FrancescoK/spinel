# An Array pushed into a typed Array literal widens the literal: through a
# boxed local whose push takes several values (push, append, unshift,
# insert), and through a parenthesized sequence whose last statement is the
# local or the literal itself.

k = ARGV.size
z = [[1], "s", {}][k]
z.push(1, [2])
p z
y = [[1], "s"][k]
y.append([3], 4)
p y
x = [[1.5], :s][k]
x.unshift(2.5, ["a"])
p x
w = [[1], nil][k]
w.insert(1, [7], 8)
p w

log = []
a = [9]
p((log << :a; a).push([3]))
p a
b = [9]
(log << :b; b) << [4]
p b
p((log << :c; [9]).push([2]))
p((log << :d; [9]) << [5, 6])
c = ["s"]
(log << :e; c).unshift([1], 2)
p c
p log
