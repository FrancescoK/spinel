# Flag-only: without the flag (as on master) each method's value is a copy
# and misses the change.
# A method whose every return path reads a String the rule shares answers
# that String's handle (published by the read, as the deep-return pickup
# takes it), wherever its call's value goes: through `then`, a `loop`
# break, a Thread's value, a yielded block's value, `map` and `inject`
# blocks, a Method object's `call`, `super`, a dispatch over two classes,
# and an argument. So does a method that answers another such method's
# value, one answering from a `rescue` arm, and a block parameter handed
# through such a method. A method answering a new String does not.
def return_param(line) = line
def via(line) = return_param(line)
def rescued(x); raise "e"; rescue; x; end
def yv = yield
def fresh(x) = x + "f"
def grow(u) = u << "g"
class A; def f(x) = x; end
class B < A; def f(x) = super; end
class C; def f(x) = x; end
s = +"a"
t = s
1.then { return_param(s) } << "1"
loop { break return_param(s) } << "2"
Thread.new { return_param(s) }.value << "3"
yv { return_param(s) } << "4"
[1].map { return_param(s) }[0] << "5"
[1].inject(nil) { |acc, x| return_param(s) } << "6"
method(:return_param).call(s) << "7"
B.new.f(s) << "8"
[A.new, C.new][s.size % 2].f(s) << "9"
via(s) << "v"
rescued(s) << "r"
grow(return_param(s))
fresh(s) << "?"
p s, t
[+"b"].each do |b|
  u = return_param(b)
  u << "x"
  p [b, u]
end
