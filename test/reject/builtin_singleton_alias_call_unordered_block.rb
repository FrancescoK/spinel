# A call that may run before the alias of a builtin class method is made cannot be ordered, so it is refused.
# spinel: reject-builtin-class: a call that may run before the singleton alias of a builtin's class method is made
at_exit { p Time.stamp.class }
f = -> { Time.stamp.class }
class Time; class << self; alias_method :stamp, :now; end; end
p f.call
