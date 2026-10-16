# A `class << self` alias of an inherited class method keeps the
# ancestor's body; a later redefinition of that class method would take its
# place, so it is refused.
# spinel: reject-builtin-class: D.o: alias of an inherited method that P defines again after it is not supported
class P
  def self.m = 1
end
class D < P
  class << self
    alias o m
  end
end
class P
  def self.m = 2
end
p D.o
