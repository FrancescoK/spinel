# spinel: reject-subclass: unsupported method_defined? (needs a compile-time-known class
# `class ::String` reopens the builtin as `class String` does: a bare
# method_defined? in it stays refused rather than answered false.
class ::String
  p method_defined?(:upcase)
end
