# included: hook redefined inside the module body between the two includes of it
module M
  def self.included(b) = puts("v1 #{b}")
end
class A; include M; end
module M
  def self.included(b) = puts("v2 #{b}")
  class Inner; include M; end
end
