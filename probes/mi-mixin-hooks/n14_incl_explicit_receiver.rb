# included: K.include(M) at the top level fires the hook
module M
  def self.included(b) = puts("inc #{b}")
end
class K; end
K.include(M)
puts K.include?(M)
