# `respond_to?(:m)` on a builtin value that travels boxed -- a Time, String
# or Integer read out of a container, or `self` inside a `class Object`
# reopening -- answers true for a method a reopening of that builtin added.
# activesupport's Object#acts_like? asks `respond_to?(:"acts_like_#{duck}?")`
# of any self, and Time#acts_like_time? comes from a `class Time` reopening;
# the check compared the boxed value's class against the reopening's table
# index, which a boxed builtin never carries, so it read false.

class Object
  def acts_like?(duck) = respond_to?(:"acts_like_#{duck}?")
end
class Time
  def acts_like_time? = true
end
class String
  def shout = upcase + "!"
end
class Integer
  def doubled = self * 2
end

p Time.at(0).acts_like?(:time), Time.at(0).acts_like?(:date)
p "s".acts_like?(:time), 5.acts_like?(:time)
mixed = [Time.at(0), "s", 5, 2.5, :sym, nil]
p mixed.map { |v| v.respond_to?(:acts_like_time?) }
p mixed.map { |v| v.respond_to?(:shout) }
p mixed.map { |v| v.respond_to?(:doubled) }
p mixed.map { |v| v.respond_to?(:to_s) }
