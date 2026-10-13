# A compact path under a constant that holds Class.new or Module.new is a
# class under that class or module, also when the path is written in
# another body. Only a Struct or Data constant is refused there.

Point = Class.new

module Geo
  class Point::Marker
    def call = "point marker"
  end
end

Util = Module.new

module App
  class Util::Helper
    def call = "util helper"
  end
end

puts Point::Marker.new.call
puts Util::Helper.new.call
