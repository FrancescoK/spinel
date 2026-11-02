# included: a module including a module fires the hook with the outer module
module M
  def self.included(b) = puts("inc #{b}")
end
module M2
  include M
end
class A; include M2; end
puts A.ancestors.take(3).inspect
