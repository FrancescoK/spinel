# alias_method takes a String or a Symbol for either name.
class A
  def y = 1
  alias_method "k", :y
  alias_method :k2, "y"
  alias_method "k3", "y"
  def z = 2
  alias_method "pz", "z"
  def via = pz
end
a = A.new
p a.k, a.k2, a.k3, a.pz, a.via
p A.instance_methods(false).sort

module M
  def z = 3
  alias_method "mz", "z"
end
class B
  include M
end
p B.new.mz

class P
  def base = 4
end
class C < P
  alias_method "cb", "base"
end
p C.new.cb

class D
  class << self
    def s = 5
    alias_method "t", "s"
  end
end
p D.t

class E
  def m = 10
  alias_method "a1", :m
  def m = 20
end
p E.new.a1, E.new.m

class LongName
  def base = :long
  alias_method "long_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", "base"
end
p LongName.new.long_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
