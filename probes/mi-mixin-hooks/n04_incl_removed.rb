# included: hook removed between two includes
module M
  def self.included(b) = puts("inc #{b}")
end
class A; include M; end
class << M
  remove_method :included
end
class B; include M; end
puts "done"
