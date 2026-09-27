# A user class whose name is a runtime value type the compiler keeps
# (Process.times' Tms, the range and rational carriers) gets a C name of its
# own, and Process.times still answers the runtime's struct beside it.
module Bench
  class Tms
    def initialize(u) = @u = u
    attr_reader :u
  end
end
class StrRange
  def initialize(a) = @a = a
  attr_reader :a
end
p Bench::Tms.new(1.5).u
p StrRange.new("x").a
p Process.times.utime >= 0.0
