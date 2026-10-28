# A receiverless call in an instance_eval or instance_exec block runs on
# the rebound receiver, and binds to the version of its method live where
# the block runs, as any call does. The version is reached only by the
# calls bound to it, and the marking asked for main's and the enclosing
# class's versions only, not the receiver's, so a version only such a call
# runs was dropped and the call took the last one: 2 for the first `v`.

class K
  def v = 1
end
o = K.new
p o.instance_eval { v }
class K
  def v = 2
end
p o.instance_eval { v }

# on one of several classes
class A
  def w = 10
end
class B
  def w = 30
end
[A.new, B.new].each { |x| p x.instance_exec { w + 1 } }
class A
  def w = 20
end
class B
  def w = 40
end
[A.new, B.new].each { |x| p x.instance_exec { w + 1 } }

# in a replaced version's body, over the interval it runs in
class L
  def g = 1
end
def h(x) = x.instance_eval { g } + 100
p h(L.new)
def h(x) = 0
class L
  def g = 2
end
p h(L.new)
p L.new.g
