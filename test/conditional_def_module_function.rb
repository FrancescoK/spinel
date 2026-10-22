# A def chosen under a run-time condition in a module_function module is
# callable on the module, with the bare form and with `module_function :m`.
# Rack::Utils picks secure_compare this way.

module Bare
  module_function

  if defined?(OpenSSL.fixed_length_secure_compare)
    def same?(a, b) = OpenSSL.fixed_length_secure_compare(a, b)
  else
    def same?(a, b) = a == b
  end

  if ENV["SPINEL_TEST_NEVER_SET"]
    def kind = "set"
  else
    def kind = "unset"
  end

  def both(a, b) = "#{kind} #{same?(a, b)}"
end

module Named
  if ENV["SPINEL_TEST_NEVER_SET"]
    def twice(x) = x * 3
  else
    def twice(x) = x * 2
  end
  module_function :twice
end

p Bare.same?("abc", "abc")
p Bare.same?("abc", "abd")
p Bare.kind
p Bare.both("x", "x")
p Named.twice(21)

# the instance copy stays private
class Host
  include Named
  def run(x) = twice(x)
end
p Host.new.run(5)
begin
  Host.new.twice(5)
rescue NoMethodError => e
  p e.class
end

# arms that take different parameters, an unless/else, and a nested module
# with the same name
module Shapes
  module_function

  if ENV["SPINEL_TEST_NEVER_SET"]
    def fmt(a) = "one #{a}"
  else
    def fmt(a, *rest, sep: ",", &blk) = [a, *rest].map(&blk).join(sep)
  end

  unless ENV["SPINEL_TEST_NEVER_SET"]
    def size = 2
  else
    def size = 1
  end

  module Inner
    module_function

    if ENV["SPINEL_TEST_NEVER_SET"]
      def size = 10
    else
      def size = 20
    end
  end
end

p Shapes.fmt(1, 2, 3, sep: "-") { |x| x * 10 }
p Shapes.size
p Shapes::Inner.size

# an arm's __method__ is the name it was written with
module Named2
  module_function

  if ENV["SPINEL_TEST_NEVER_SET"]
    def pick = [__method__, 1]
  else
    def pick = [__method__, 2]
  end
end
p Named2.pick

# the first arm, chosen when the condition holds
ENV["SPINEL_TEST_NEVER_SET"] = "1"
module BareTrue
  module_function

  if ENV["SPINEL_TEST_NEVER_SET"]
    def kind = "set"
  else
    def kind = "unset"
  end
end

module NamedTrue
  if ENV["SPINEL_TEST_NEVER_SET"]
    def twice(x) = x * 3
  else
    def twice(x) = x * 2
  end
  module_function :twice
end
ENV.delete("SPINEL_TEST_NEVER_SET")

p BareTrue.kind
p NamedTrue.twice(21)
