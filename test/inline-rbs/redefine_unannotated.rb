# One opening of K annotates m; a later opening replaces m with an
# unannotated definition. The replacement is the method the call reaches, and
# the annotation says nothing about it: it must not be checked against
# `String`. Either the annotation is applied to its own definition only, or
# it is reported, naming both definitions, and ignored whole.
class K
  #: (String) -> String
  def m(x) = x
end

class K
  def m(x) = x
end

p K.new.m(1)
