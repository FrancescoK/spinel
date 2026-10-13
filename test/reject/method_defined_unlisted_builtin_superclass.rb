# spinel: reject-subclass: unsupported method_defined? (needs a compile-time-known class
# method_defined? answers a builtin's methods from CRuby's table of the core
# classes (src/core_class_methods.inc). Errno::ENOENT is not in it, so a
# name a subclass of it does not define stays refused (CRuby: true).
class Missing < Errno::ENOENT; end
p Missing.method_defined?(:errno)
