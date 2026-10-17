# defined?(P::NAME) asks whether NAME is P's, even beside a const_set
# whose name is computed: here a user class's own const_set, which places
# no constant at all. (Module#const_set with a computed name is refused;
# with a literal one it re-assigns a constant the program already has.)
module Fmt
  VERSION = "1"
end

module Cache
  class Coder; end
end

class Registry
  def initialize = @h = {}
  def const_set(k, v) = @h[k] = v
  def [](k) = @h[k]
end

reg = Registry.new
key = ["Coder", "Other"][ARGV.size]
reg.const_set(key, 1)
p reg["Coder"]

p defined?(Fmt::Coder)
p defined?(::Fmt::Coder)
p(defined?(::Fmt::Coder) && Fmt::Coder.new)
p defined?(Cache::Coder)
p defined?(Fmt::VERSION)
