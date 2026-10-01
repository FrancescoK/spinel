# respond_to?'s type follows what answers it. On a receiver held boxed the
# compile-time fold answers, a Boolean, whatever value it is; one class of
# the program overriding respond_to? with another kind of answer typed the
# call as any value, and the fold's Boolean went where a boxed value was
# read -- activesupport's `logger.respond_to?(:local_level=)` and
# `subscriber.respond_to?(:report)`. On a receiver of that class the
# override answers, and its :yes was read as a Boolean. Neither compiled.
class Weird
  def respond_to?(m, priv = false) = m == :report ? :yes : nil
end

class Sub
  def report = 1
end

x = [Sub.new, Weird.new, 3][ARGV.size]
p x.respond_to?(:report)
puts "yes" if x.respond_to?(:report)
p Weird.new.respond_to?(:report)
p [1, "s"][ARGV.size].respond_to?(:upcase)
