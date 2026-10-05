# Inside a class method of a reopened Time, a bare `at` (or `now`, `utc`,
# ...) is Time's own constructor, and so is an alias the reopening gives
# it: activesupport's Time.at_with_coercion calls `at_without_coercion(x,
# *args)`, the builtin `at` kept under that name. The call was refused for
# want of a receiver.
class Time
  class << self
    def at_plus(x, *args) = at(x + 1, *args)
    def at_with_coercion(x, *args)
      x = x.to_i if x.is_a?(String)
      at_without_coercion(x, *args)
    end
    alias_method :at_without_coercion, :at
    def epoch_utc = utc(1970, 1, 1)
  end
end
p Time.at_plus(5).to_i
p Time.at_plus(5, 500, :millisecond).usec
p Time.at_with_coercion("7").to_i
p Time.at_with_coercion(8, 250).usec
p Time.epoch_utc.to_i
