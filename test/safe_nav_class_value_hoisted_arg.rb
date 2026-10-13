# `@writer&.call("x#{n}")` on a boxed writer, in a program where a class also
# defines a class method `call`: the call dispatches on the receiver being a
# Class first, with its computed argument hoisted to one boxed temp that each
# arm reads. The safe navigation's arm asked the analysis for the call's
# natural type while that temp was in effect, and the answer recorded the
# argument's own type (String) over the temp's (boxed): the not-a-Class
# fallback then boxed the boxed temp again as a String, and the C did not
# build.
class P
  def initialize(writer: nil) = @writer = writer
  def report(n) = @writer&.call("x#{n}")
end

class W
  def call(s) = puts("W #{s}")
end

class K
  def self.call(a, b) = puts("K #{a} #{b}")
end

P.new(writer: ->(s) { puts s }).report(1)
P.new(writer: W.new).report(2)
P.new(writer: method(:puts)).report(3)
p P.new.report(4)
