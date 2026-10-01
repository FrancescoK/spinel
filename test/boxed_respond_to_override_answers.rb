# A boxed value of a class whose own respond_to? answers something other
# than true or false gets that answer, not the compile-time fold's Boolean
# read out of it. A class that overrides respond_to? but is never made does
# not stop the fold from answering a Boolean for the other values.
class Weird
  def respond_to?(m, priv = false) = m == :report ? :yes : nil
end

class Sub
  def report = 1
end

class Never
  def respond_to?(m, priv = false) = m
end

x = [Weird.new, Sub.new, 3][ARGV.size]
p x.respond_to?(:report)
p x.respond_to?(:zzz)
puts "yes" if x.respond_to?(:report)
puts "no" unless x.respond_to?(:zzz)
y = [Sub.new, Weird.new][ARGV.size]
p y.respond_to?(:report)
v = [1, "s"][ARGV.size]
p v.respond_to?(:upcase)
puts "succ" if v.respond_to?(:succ)
