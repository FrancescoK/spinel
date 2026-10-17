# defined?(P::NAME) asks whether NAME is P's, even in a program that
# re-assigns constants with const_set: a const_set with a literal name
# can only place that name, so another leaf a module lacks stays missing,
# though a constant of that name lives elsewhere.
module Fmt
  VERSION = "1"
end

module Cache
  class Coder; end
end

class Box
  X = 1
end

Box.const_set(:X, 2)

p defined?(Fmt::Coder)
p defined?(::Fmt::Coder)
p(defined?(::Fmt::Coder) && Fmt::Coder.new)
p defined?(Cache::Coder)
p defined?(Box::X)
p Box::X
p defined?(Fmt::VERSION)
p defined?(Box::VERSION)
