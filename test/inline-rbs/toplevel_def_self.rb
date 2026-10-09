# An annotation on a top-level `def self.` method, a singleton method of the
# main object. It is applied, or reported at its line; it is never dropped
# without a word. (--rbs has no spelling for it: `class Object` with
# `def self.tl` names a method of Object's singleton class.)
#: (untyped) -> untyped
def self.tl(x)
  x
end

p tl(3)
