# `x.to_i(16)` on a value of any type: only String#to_i takes a radix, but
# a class of the program taking an argument in its own to_i (a value
# wrapper's `def to_i(*args) = @v.to_i(*args)`) makes the call's answer any
# value. The radix form answered an Integer regardless, unboxed in that
# slot, and the C did not compile. The dispatch now has a String arm for it
# beside the class's own.
class Num
  def initialize(v) = @v = v
  def to_i(*args) = @v.to_i(*args)
end

x = ["ff", Num.new("10"), 5][ARGV.size]
p x.to_i(16)
y = [Num.new("7"), "z"][ARGV.size]
p y.to_i(36)
begin
  p [5, "1"][ARGV.size].to_i(2)
rescue ArgumentError => e
  p e.message
end
p "11".to_i(2)
