# `x <=> x` answers 0 for an object with no `<=>` of its own, whatever class it
# is (a Regexp, an Exception, a Proc, a Thread and the rest); a different
# object that is not equal to it, or one of another class, answers nil.
require "socket"

def cmp(a, b) = a <=> b

e = RuntimeError.new("x")
e3 = RuntimeError.new("y")
p [e <=> e, e <=> e3, e <=> 1, e <=> nil, e <=> "x"]

m = "abc".match(/b/)
m3 = "abc".match(/c/)
p [m <=> m, m <=> m3, m <=> "x"]

r = /a/
r3 = /b/
p [r <=> r, r <=> r3, r <=> 1, r <=> nil]

pr = proc { 1 }
pr2 = proc { 1 }
p [pr <=> pr, pr <=> pr2, pr <=> 1]

th = Thread.new { 1 }
th2 = Thread.new { 2 }
th.join
th2.join
p [th <=> th, th <=> th2, th <=> 1]

mu = Mutex.new
mu2 = Mutex.new
p [mu <=> mu, mu <=> mu2, mu <=> 1]

q = Queue.new
q2 = Queue.new
sq = SizedQueue.new(1)
p [q <=> q, q <=> q2, sq <=> sq, sq <=> q, q <=> 1]

cv = ConditionVariable.new
cv2 = ConditionVariable.new
p [cv <=> cv, cv <=> cv2, cv <=> 1]

f = Fiber.new { 1 }
f2 = Fiber.new { 1 }
p [f <=> f, f <=> f2, f <=> 1]

en = [1, 2].each
en2 = [1, 2].each
p [en <=> en, en <=> en2, en <=> 1]

ra = Random.new(1)
ra3 = Random.new(2)
p [ra <=> ra, ra <=> ra3, ra <=> 1]

me = 1.method(:+)
me3 = 2.method(:+)
um = me.unbind
p [me <=> me, me <=> me3, me <=> 1, um <=> um, um <=> 1]

ai = Addrinfo.tcp("127.0.0.1", 80)
ai2 = Addrinfo.tcp("127.0.0.1", 80)
p [ai <=> ai, ai <=> ai2, ai <=> 1]

# the same values through a method's parameters, and in a box
p cmp(e, e), cmp(r, r), cmp(pr, pr), cmp(th, th), cmp(mu, mu), cmp(q, q), cmp(en, en)
p cmp(e, r), cmp(r, 1), cmp(1, r)
box = [e, r, pr, th, mu, q, 1, nil]
box.each_with_index { |x, i| p [x <=> box[i], x <=> box[(i + 1) % box.size]] }

# an operand of a class of the program
class Foo; end
p [r <=> Foo.new, e <=> Foo.new, pr <=> Foo.new, th <=> Foo.new]

# an Exception compared with an instance of an exception class of the program
class MyErr < StandardError; end
u = MyErr.new("u")
v = MyErr.new("v")
ex = begin
  raise u
rescue => x
  x
end
p [ex <=> u, ex <=> v, u <=> u, e <=> u]

# a Hash and an object of a class that defines nothing
h = { a: 1 }
o = Object.new
p [h <=> h, h <=> { a: 1 }, h <=> 1, o <=> o, o <=> Object.new]

# an operand that runs code runs once, receiver first
log = []
p((log << :recv; e) <=> (log << :arg; e3))
p log
log = []
p((log << :recv; mu) <=> (log << :arg; mu))
p log
log = []
p((log << :recv; pr) <=> (log << :arg; 1))
p log
log = []
p((log << :recv; q) <=> (log << :arg; q2))
p log
