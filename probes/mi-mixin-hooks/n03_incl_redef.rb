# included: hook redefined between two includes
module M
  def self.included(b) = puts("v1 #{b}")
end
class A; include M; end
module M
  def self.included(b) = puts("v2 #{b}")
end
class B; include M; end
