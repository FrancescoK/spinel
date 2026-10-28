# A method defined again runs, for each call, the definition in effect
# where the call runs: a call in a class or module body between the two
# definitions, of an instance method or of a module's own method, and a
# call on a subclass before the subclass overrides the method, which
# reaches the superclass's.
class C
  def v = 1
  X = new.v
  def v = 2
  Y = new.v
end
p C::X, C::Y
module M
  def self.k = :a
  A = k
  def self.k = :b
end
p M::A, M.k
class P
  def get = 1
end
class S < P
end
p S.new.get
class S
  def get = 5
end
p S.new.get
