# spinel: reject-subclass: the ancestry and the method table of a singleton class are not modeled
# A singleton class is a value of its own (#<Class:Shape>), but its ancestors
# (#<Class:Shape>, #<Class:Object>, ..., Class, Module, ...) are not modeled:
# refused rather than answered as for some other class.
class Shape
  class << self
    p ancestors.first
  end
end
