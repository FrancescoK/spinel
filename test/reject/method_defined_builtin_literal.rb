# spinel: reject-subclass: unsupported method_defined? (needs a compile-time-known class
# method_defined? of a builtin class does not know the builtin's own methods,
# so a literal one stays refused rather than answered false (CRuby: true).
p String.method_defined?(:upcase)
