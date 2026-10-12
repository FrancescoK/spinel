# respond_to?(name, true) includes private methods, and every object has
# Object's private ones (Kernel's exit, puts, raise, ...): true for a user
# object, a builtin value, a value only known at run time, and a name only
# known at run time (or a user object's flag). A class that undefines one,
# or defines a public or private method of that name, answers by its own.
class A
  def puts(x); end
end
class B
  private def exit; end
end
class U
  undef_method :sleep
end
class Sup
  def respond_to?(m, include_all = false)
    return true if m == :zzz
    super
  end
end
class Klass
  def chk; respond_to?(:raise, true); end
  def chk2; respond_to?(:raise); end
end
p [A.new.respond_to?(:puts), A.new.respond_to?(:puts, true)]
p [B.new.respond_to?(:exit), B.new.respond_to?(:exit, true)]
p [U.new.respond_to?(:sleep, true), U.new.respond_to?(:exit, true)]
p [Sup.new.respond_to?(:zzz), Sup.new.respond_to?(:exit, true), Sup.new.respond_to?(:exit), Sup.new.respond_to?(:nope, true)]
p [Klass.new.chk, Klass.new.chk2]
p [$stdout.respond_to?(:puts), $stdout.respond_to?(:exit, true), $stdout.respond_to?(:exit)]
p [nil.respond_to?(:raise, true), 1.respond_to?(:format, true), "s".respond_to?(:exit!, true), :s.respond_to?(:sleep, true)]
p [[1].respond_to?(:select), [1].respond_to?(:select, true), [1].respond_to?(:sleep, true), {}.respond_to?(:loop, true)]
p [1.5.respond_to?(:exit, true), (1..2).respond_to?(:exit, true), A.new.respond_to?(:exit?, true)]

ys = [1, "a", A.new, nil, U.new]
p ys.map { |y| y.respond_to?(:sleep, true) }
p ys.map { |y| y.respond_to?(:puts, true) }
p ys.map { |y| y.respond_to?(:puts) }
names = [:exit, :puts, :sleep, :bogus, :initialize]
p ys.map { |y| names.map { |n| y.respond_to?(n, true) } }
p ys.map { |y| names.map { |n| y.respond_to?(n) } }

# the flag at run time
def chk(obj, meth, include_all: false)
  obj.respond_to?(meth, include_all)
end
p [chk(A.new, :exit, include_all: true), chk(A.new, :exit), chk(A.new, :exit?, include_all: true)]
p [chk("blah", :missing, include_all: true), chk("blah", :puts, include_all: true), chk("blah", :puts)]
p [chk(1, :raise, include_all: true), chk(nil, :sleep, include_all: true), chk(U.new, :sleep, include_all: true)]
class Foo; def bar; end; private def baz; end; end
flag = ys.size > 2
f = Foo.new
p [f.respond_to?(:exit, flag), f.respond_to?(:baz, flag), f.respond_to?(:exit, !flag), f.respond_to?(:bar, !flag)]
