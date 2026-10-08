# CRuby refuses to load this: "Kernel is not a class (TypeError)".
# Kernel is a builtin module, so `class Kernel` cannot reopen it.
# spinel: reject-builtin-module: Kernel is not a class (TypeError)
class Kernel
  def greet = "hi"
end

puts Kernel.class
