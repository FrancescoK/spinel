# Regression (#4395): a poly `.call` result is typed poly (the slot may hold a
# Proc, whose return is dynamic), so `o.method(:sym)` on that result has no
# concrete target to bind. The bind's `(void *)(<poly expr>)` self slot once
# failed to compile ("cannot convert to a pointer type"). A boxed receiver now
# binds a wrapper that carries it and dispatches the call at run time, so the
# Method works as it does in CRuby, and a concrete receiver still binds
# directly.

class Obj
  def foo(x) = x + 1
end

class Number
  def call = Obj.new
end

slots = [Number.new]
o = slots[0].call
begin
  m = o.method(:foo)
  puts m.call(5)
rescue NoMethodError => e
  puts "poly_bind: #{e.class}"
end

# A concrete receiver keeps working.
o2 = Obj.new
m2 = o2.method(:foo)
puts m2.call(5)

# A poly class value: the same decline, not a broken build.
kclass = [Obj, nil][0]
begin
  kclass.method(:new)
  puts "poly_class_bind: no raise"
rescue NoMethodError
  puts "poly_class_bind: NoMethodError"
end
