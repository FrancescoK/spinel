# An Integer or a Float parameter a nil reaches through a VALUE rather than a
# literal nil is marked nullable too, so it reads back as nil: a yield of
# `i == 0 ? nil : i` or of a local copied from a missed read (inline, handed
# on with &b, through instance_exec), a Method's `call` and its to_proc (a
# positional or a keyword parameter), and a builtin iterator's element
# parameter beside another one (each_with_index, each_with_object,
# map.with_index, each.with_index, inject, sort) or as `_1` or `it`.

def f(i) = yield(i == 0 ? nil : i)
f(0) { |a| p [a, Integer === a] }
f(3) { |a| p [a, Integer === a] }
def g(i) = yield(i == 0 ? nil : 1.5)
g(0) { |a| p [a, Float === a] }
def h(v) = yield(v)
m = [4][ARGV.size + 2]
h(m) { |a| p [a, Integer === a] }
def fw(i, &b) = f(i, &b)
fw(0) { |a| p [a, Integer === a] }
class C; end
C.new.instance_exec(ARGV.size == 0 ? nil : 2.5) { |a| p [a, Float === a] }
def ie(i, &b) = C.new.instance_exec(i == 0 ? nil : i, &b)
ie(0) { |a| p [a, Integer === a] }

def mf(a, x = 1.5) = p([a, x, Float === x])
def mi(a, k = 1) = p([a, k, Integer === k])
def mk(a, k: 2.5) = p([a, k, Float === k])
method(:mf).call(1, nil)
method(:mf).to_proc.call(2, nil)
method(:mi).call(3, nil)
method(:mi).to_proc.call(4, nil)
def run(mo, v) = mo.call(5, v)
run(method(:mf), nil)
run(method(:mi), nil)
run(method(:mf), 6.5)
method(:mk).call(7, k: nil)
mk(8, k: nil)

y = [1.5, [2.5][ARGV.size + 5]]
x = [1, [2][ARGV.size + 5]]
y.each_with_index { |e, i| p [e, i] }
x.each_with_index { |e, i| p [e, i, Integer === e] }
x.each_with_object([]) { |e, acc| p [e, Integer === e] }
y.map.with_index(1) { |e, i| p [e, i] }
x.each.with_index { |e, i| p [i, Integer === e] }
x.each_with_index.map { |e, i| p [i, Integer === e] }
p(x.sort { |a, b| p [Integer === a, Integer === b]; 0 })
x.each { p Integer === _1 }
x.each { p Integer === it }
p(x.inject { |s, e| p [s, Integer === e]; s })
