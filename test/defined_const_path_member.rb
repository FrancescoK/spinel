# defined?(P::NAME) is "constant" only when NAME is a constant of P (nested
# in it, written in it, or its ancestors'), not wherever a constant of that
# last name lives: each segment was looked up by its own name, so
# `defined?(Lib::Coder)` answered "constant" for a Cache::Coder alone, and
# its true arm then read what Lib does not have.

module Cache
  class Coder
    def dump(x) = x
  end
end
module Lib
  VERSION = "1"
end
module A
  module B
    C = 1
  end
end
module X
  module B
    D = 2
  end
end
class Base
  K = :k
end
class Sub < Base; end

p defined?(Lib::Coder)
p defined?(::Lib::Coder)
p defined?(Cache::Coder)
p defined?(Lib::VERSION)
p defined?(A::B::C)
p defined?(A::C)
p defined?(X::B::D)
p defined?(A::B::D)
p defined?(Sub::K)
p defined?(Float::INFINITY)
p defined?(Encoding::UTF_8)
p(defined?(Lib::Coder) ? Lib::Coder.new : :no_coder)
