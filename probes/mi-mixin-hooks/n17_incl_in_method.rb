# included: include run by a method called at load time
module M
  def self.included(b) = puts("inc #{b}")
end
class A; end
class B; end
def add(k) = k.include(M)
add(A)
add(B)
puts B.include?(M)
