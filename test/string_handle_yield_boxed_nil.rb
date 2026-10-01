# A parameter that became the shared handle for a boxed block parameter
# (#6499) still takes nil: a nil argument, a nil local beside a String, and
# an omitted optional bind nil rather than a box around a NULL handle.

def run(s) = s.size
class Foo
  def run(x) = yield(x)
  def go(v) = run(v) { |t| t << "!" * 10 if t; t }
end
v = +"v"; Foo.new.go(v); p v.size
p Foo.new.go(nil)

def run2(x) = yield(x)
def outer(y) = run2(y) { |t| t << "!" unless t.nil?; t }
def kall(...) = run2(...)
s = +"a"; outer(s); p s
p kall(1) { |q| q }
p outer(nil)
n = nil; p outer(n)

class K; def ap(s) = (s << "!" if s; s); end
def go2(v) = K.new.ap(v)
m = K.new.method(:ap)
x = +"x"; m.call(x); p x
y = +"y"; go2(y); p y
p go2(nil)
z = nil; p go2(z)

# &method(:g) handed through a class method with a constant receiver
def g(t) = t.size
module KR; def self.krun(x, &b) = b.call(x); end
def kfwd(x, &b) = KR.krun(x, &b)
p kfwd("abcd", &method(:g))
p KR.krun("abc", &method(:g))
