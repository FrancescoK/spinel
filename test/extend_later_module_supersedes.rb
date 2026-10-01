# A class that extends two modules defining the same method answers the
# later module's, whose super reaches the earlier one, as CRuby's singleton
# ancestors do. The first module's copy took the name and the later one was
# skipped, so `super` in it never ran.

module M1
  def foo = [:m1]
  def bar = :bar1
end
module M2
  def foo = [:m2, *super]
end
module M3
  def foo = [:m3, *super]
end

class K
  extend M1
  extend M2
  extend M3
end
p K.foo, K.bar

# `extend A, B` extends B first, so A comes first
class L
  extend M2, M1
end
p L.foo

# the class's own method still wins
class N
  def self.foo = [:own]
  extend M1
  extend M2
end
p N.foo

# a later module without super simply replaces the earlier one
module Q
  def foo = :q
end
class R
  extend M1
  extend Q
end
p R.foo

# super past the extended modules reaches the superclass's class method
class Base3
  def self.foo = [:base]
end
class Sub3 < Base3
  extend M2
end
p Sub3.foo

# extending a module the class already extends is a no-op, also in a
# reopening and within one `extend`: it stays behind the later module
class S1
  extend M1
  extend M2
  extend M1
end
p S1.foo
class S2
  extend M1, M2, M1
end
p S2.foo
class S3
  extend M1
end
class S3
  extend M2
  extend M1
end
p S3.foo

# super into an earlier module's method that yields: with a literal block,
# forwarding the caller's block bare or by name, and next to a yield
module Y1
  def foo(a = 7) = yield(a)
end
module Y2
  def foo = super { |x| x + 1 }
end
module Y3
  def foo = super
end
module Y4
  def foo(&b) = super(3, &b)
end
module Y5
  def foo = [yield(1), super { |x| x * 10 }]
end
class T2
  extend Y1
  extend Y2
end
class T3
  extend Y1
  extend Y3
end
class T4
  extend Y1
  extend Y4
end
class T5
  extend Y1
  extend Y5
end
p T2.foo
p T3.foo { |x| x - 1 }
p T4.foo { |x| x * 3 }
p T5.foo { |x| x + 100 }

# and the same through an include or prepend chain's earlier module
class U1
  include Y1
  include Y2
end
class U2
  include Y1
  include Y3
end
class U3
  prepend Y1
  prepend Y5
  def foo(a = 0) = a
end
p U1.new.foo
p U2.new.foo { |x| x - 2 }
p U3.new.foo { |x| x + 200 }
