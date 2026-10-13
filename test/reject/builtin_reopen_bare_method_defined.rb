# spinel: reject-subclass: unsupported method_defined? (needs a compile-time-known class
# A reopened builtin class answers method_defined? for the program's own
# methods alone, so a bare one in its body (CRuby: true here) stays refused
# rather than answered false.
class String
  p method_defined?(:upcase)
end
