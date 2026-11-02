# included: including twice fires twice (CRuby calls the hook each time)
module M
  def self.included(b) = puts("inc #{b}")
end
class A
  include M
  include M
end
