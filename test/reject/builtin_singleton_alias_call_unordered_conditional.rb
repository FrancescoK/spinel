# A call that may run before the alias of a builtin class method is made cannot be ordered, so it is refused.
# spinel: reject-builtin-class: a call that may run before the singleton alias of a builtin's class method is made
3.times do |i|
  class Time; class << self; alias_method :stamp, :now; end; end if i == 1
  p((Time.stamp.class rescue :nomethod))
end
