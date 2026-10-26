# The methods the compiler makes for its own lowering are no Ruby methods:
# the enumerator's `__enumw_map`, a builtin's per-call-site copy
# (`__enum_count__0`, `__int_double__0` for a program's own Integer
# method), ThreadGroup's `__remove`. No reflection and no send with a name
# known only at run time sees them; a method the program itself names with
# a leading `__` stays visible, also where a builtin's helper has the same
# name (a program's own `Box#__remove` beside ThreadGroup's).

class Integer
  def double = self * 2
end

def __int_twice(x) = x * 2

class Box
  def __cmp_key = 7
  def __remove(x) = "box #{x}"
  def go = 1
end

a = [3, 1, 2]
p a.map.with_index { |x, i| x * i }
p a.count { |x| x > 1 }
p 3.double, __int_twice(4)

HELPERS = %w[__enumw_map __enum_count__0 __int_double__0 __remove]
HELPERS.each do |n|
  s = n.to_sym
  p [n, respond_to?(n, true), respond_to?(s), Box.new.respond_to?(s, true), 3.respond_to?(s, true)]
  p [n, (send("#{n}", a) rescue $!.class), (__send__(:"#{n}", a) rescue $!.class),
     (public_send("#{n}", a) rescue $!.class)]
  p [n, Object.private_method_defined?(s), Box.method_defined?(s)]
end

g = ThreadGroup.new
p g.list
%w[__remove __member?].each do |n|
  p [n, g.respond_to?(n, true), ThreadGroup.method_defined?(n), (g.send("#{n}", Thread.current) rescue $!.class)]
end
p g.respond_to?("list".dup), ThreadGroup.method_defined?("list".dup)
p g.methods.grep(/\A__[rm]/), ThreadGroup.instance_methods.grep(/\A__[rm]/)
p((g.method(:__remove) rescue $!.class))

%w[__int_twice __cmp_key go].each do |n|
  p [n, respond_to?(n, true), Box.new.respond_to?(n), Box.method_defined?(n)]
end
p Box.instance_methods(false).sort
p send("__int_twice", 5), Box.new.send("__cmp_key")
b = Box.new
%w[__remove].each do |n|
  p [n, b.respond_to?(n), Box.method_defined?(n), b.send("#{n}", 1), b.method(:__remove).call(2)]
  p [n, g.respond_to?(n, true), ThreadGroup.method_defined?(n), (g.send("#{n}", Thread.current) rescue $!.class)]
end
p b.methods.grep(/\A__r/), g.methods.grep(/\A__r/), Box.instance_methods(false).sort
