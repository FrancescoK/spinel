# A method annotated the same way in two openings of its class, the second
# definition replacing the first. The annotations agree, so there is no
# message, and both definitions take the signature. (--rbs names the method,
# not a definition, and so has no equivalent to compare with.)
class K
  #: (untyped) -> untyped
  def m(x) = x
end

class K
  #: (untyped) -> untyped
  def m(x) = x
end

p K.new.m(3)
