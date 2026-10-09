# An annotated def replaced by a def whose own annotation is ignored: a
# generic signature, which Spinel cannot pin. Neither is applied, and each is
# reported -- the second for what it is, the first for being replaced by a
# definition without an applied annotation.
class K
  #: (String) -> String
  def m(x) = x
end

class K
  #: [U] (U) -> U
  def m(x) = x
end

p K.new.m(1)
