# Module#constants lists the classes and modules defined through a path
# from outside the module's body (`class Outer::Inner::A`), and a constant
# assigned through one at the top level (`Outer::Inner::LIMIT = 3`). They
# were missing from the listing, and a runtime-name const_get of them raised
# NameError. A path header written in another module's body (`class
# Box::Lid` inside Inner) names a constant of Box, not of Inner. The listings
# are sorted: CRuby does not list constants in the order they were assigned.

module Outer
  module Inner
    class Base; end
    PATTERN = /\AStep\d+\z/
    class Box; end
    class Box::Lid; end
  end
end

class Outer::Inner::Step1 < Outer::Inner::Base; end
module Outer::Inner
  class Step3 < Base; end
end
class Outer::Inner::Step2 < Outer::Inner::Base
  class Deep; end
end
module Outer::Inner::Helpers; end
Outer::Inner::LIMIT = 3

p Outer::Inner.constants.sort
p Outer::Inner::Box.constants
p Outer::Inner::Step2.constants
p Outer.constants

steps = Outer::Inner.constants.select { |n| n =~ Outer::Inner::PATTERN }.sort
p steps
p steps.map { |n| Outer::Inner.const_get(n) }
p steps.map { |n| Outer::Inner.const_get(n) < Outer::Inner::Base }
p Outer::Inner.const_get(ARGV.size > 3 ? "x" : "LIMIT")
p Outer::Inner.const_get(ARGV.size > 3 ? "x" : "Helpers")
p Outer::Inner.const_defined?(ARGV.size > 3 ? "x" : "Step1")

mod = ARGV.size > 3 ? Outer : Outer::Inner
p mod.constants.sort
p mod.const_get(steps.first)
p mod.const_get(ARGV.size > 3 ? "x" : "LIMIT")
