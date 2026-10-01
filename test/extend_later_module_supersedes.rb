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
