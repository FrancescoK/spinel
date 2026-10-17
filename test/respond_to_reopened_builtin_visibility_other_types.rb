# K-028 (kilau docs/CATALOG.md) fixed respond_to?/direct calls for a
# private/protected reopening of Array/Hash's OWN methods. This covers the
# types that fix missed: Integer and Symbol answered true here because
# `qm` ("to_s") is in respond_universal[] (Object's public method names),
# checked before any receiver-specific visibility; Range answered true
# because its early "leave unresolved" branch (TY_RANGE/TY_FLOAT_RANGE/
# TY_STR_RANGE) ran before a visibility check could too. The direct call
# already raised correctly for all three (emit_vis_refusal's fix is
# type-agnostic via builtin_class_of_type) -- only respond_to? itself
# was still wrong.

class Integer
  private :to_s
end
p 5.respond_to?(:to_s)
p 5.respond_to?(:to_s, true)

class Range
  private :min
end
p (1..3).respond_to?(:min)
p (1..3).respond_to?(:min, true)

class Symbol
  private :to_s
end
p :abc.respond_to?(:to_s)
p :abc.respond_to?(:to_s, true)

# an untouched builtin method on the same reopened classes still answers
# true
p 5.respond_to?(:+)
p (1..3).respond_to?(:max)
p :abc.respond_to?(:to_sym)
