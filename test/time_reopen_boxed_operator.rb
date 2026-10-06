# An operator a reopened Time defines answers for a boxed Time as for a
# typed one: activesupport chains Time#- through minus_with_coercion to
# take a Duration. The boxed-operator table had no arm for a reopened
# builtin that could match (its key was the reopening's class index, not
# Time's), the hook was never asked for a builtin receiver, and the arm it
# wrote named a function that does not exist.
class Dur
  attr_reader :sec
  def initialize(s) = @sec = s
end
class Time
  def minus_with_coercion(other)
    other = other.sec if other.is_a?(Dur)
    minus_without_coercion(other)
  end
  alias_method :minus_without_coercion, :-
  alias_method :-, :minus_with_coercion
end
t = Time.at(100)
p (t - Dur.new(10)).to_i
vals = [t, 5]
p (vals[0] - Dur.new(30)).to_i
p (vals[0] - 1).to_i
