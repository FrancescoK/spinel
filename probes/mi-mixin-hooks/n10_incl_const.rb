# included: the hook writes a constant on the base
module M
  def self.included(b) = b.const_set(:FROM_M, 1)
end
class A; include M; end
puts A::FROM_M
