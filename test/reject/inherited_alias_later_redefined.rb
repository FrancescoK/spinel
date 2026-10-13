# An alias of an inherited method keeps the ancestor's body in effect where
# it appears; a later redefinition in the ancestor would take its place,
# so it is refused.
# spinel: reject-builtin-class: D#o: alias of an inherited method that P defines again after it is not supported
class P
  def m = 1
end
class D < P
  alias o m
end
class P
  def m = 2
end
p D.new.o
