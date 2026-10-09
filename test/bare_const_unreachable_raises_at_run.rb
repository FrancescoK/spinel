# X is defined only as A::X. CRuby's lookup from the top level, or from B,
# never looks inside A, so reading `X` raises NameError when it runs -- and
# only then: a method that reads it and is never called is fine. spinel
# refused the whole program; the read now raises as CRuby's does.
module A
  class X; def w = "A::X"; end
end
def g = X.new.w
class B
  def self.never = X
  def self.ok = :ok
end
p B.ok
begin
  g
rescue NameError => e
  p e.class, e.message
end
begin
  B.never
rescue NameError => e
  p e.message
end
p defined?(X), A::X.new.w
