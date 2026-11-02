# included: a private hook still fires
module M
  def self.included(b) = puts("inc #{b}")
  private_class_method :included
end
class A; include M; end
puts M.respond_to?(:included)
