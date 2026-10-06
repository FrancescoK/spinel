# CRuby refuses to load this: "Kernel is not a class (TypeError)".
# A block does not open a new constant scope, so `class Kernel` in a
# Class.new block names the builtin module Kernel.
Widget = Class.new do
  class Kernel
  end
end

puts Widget.class
