# A bare `super` into Array passes the method's parameters on, and from a
# method with a parameter after its rest parameter there is no spelling of
# Array's call that does yet (#7449): refused, with the explicit form
# suggested.
# spinel: reject-subclass: a bare `super` into Array from a method with keyword, post-rest
class Filled < Array
  def initialize(*sizes, value)
    super
  end
end

p Filled.new(3, 0)
