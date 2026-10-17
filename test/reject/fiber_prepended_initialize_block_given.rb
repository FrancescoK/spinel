# A prepended Fiber#initialize that asks block_given? (or yields) is not run
# as __spinel_init: that call has no block, so it would answer false where
# CRuby answers true (#9433). Refused, not answered wrongly.
class Fiber
  module Given
    def initialize(**options, &block)
      @given = block_given?
      super(**options, &block)
    end
    attr_reader :given
  end
end
Fiber.prepend(Fiber::Given)
f = Fiber.new { 1 }
p f.given
p f.resume
