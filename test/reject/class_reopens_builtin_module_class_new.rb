# CRuby refuses to load this: "Kernel is not a class (TypeError)".
# A block does not open a new constant scope, so `class Kernel` in a
# Class.new block names the builtin module Kernel.
# spinel: reject-builtin-module: Kernel is not a class (TypeError)
Widget = Class.new do
  class Kernel
  end
end

puts Widget.class
