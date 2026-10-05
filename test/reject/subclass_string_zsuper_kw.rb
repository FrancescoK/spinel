# A bare `super` into String passes the method's parameters on, and from a
# method with a keyword parameter there is no spelling of String's call that
# does yet (#7449): refused, with the explicit form suggested.
class Padded < String
  def center(width, pad: " ")
    super
  end
end

p Padded.new("a").center(5)
