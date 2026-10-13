# spinel: reject-subclass: unsupported call: node
# A reopened builtin class answers instance_method for the program's own
# methods alone, so a bare one in its body (CRuby: String#upcase) stays
# refused rather than answered without the builtin's method.
class String
  p instance_method(:upcase)
end
