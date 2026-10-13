# A compact path under a Struct constant, written in a module, is
# Point::Helper in CRuby, not Geo::Helper. Point is written at the top level,
# not in Geo. A read of Point::Helper would reach the top-level Helper
# beside it, so the compiler refuses the program.
# spinel: reject-compact-path: a constant that holds a Struct or Data class, is not supported here
Point = Struct.new(:x)

module Geo
  class Point::Helper
    def call = "point helper"
  end
end

class Helper
  def call = "top helper"
end

puts Point::Helper.new.call
puts Helper.new.call
