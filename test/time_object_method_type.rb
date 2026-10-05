# A program's own Object method called on a Time answers what it returns,
# whatever its name says: here Object#acts_like? gives respond_to?'s
# answer, which a delegator's respond_to? gives boxed. On a Time receiver
# (self in Time's reopening) the call was typed a bool by its name's `?`
# before the Object method was asked, the method answered boxed, and the
# C did not compile. activesupport's Time#in_time_zone asks
# `acts_like?(:time)` this way.
class Proxy
  def initialize(t) = @t = t
  def target = @t
  def respond_to?(name, priv = false) = priv ? target : target.respond_to?(name)
end
class Object
  def acts_like?(duck)
    case duck
    when :time then respond_to? :acts_like_time?
    else respond_to? :"acts_like_#{duck}?"
    end
  end
end
class Time
  def acts_like_time? = true
  def maybe_self = acts_like?(:time) ? self : nil
end
p Time.at(0).maybe_self.class
p 1.acts_like?(:time)
p Proxy.new(Time.at(0)).acts_like?(:time)
p Proxy.new("str").acts_like?(:time)
