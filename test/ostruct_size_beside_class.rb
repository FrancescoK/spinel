# size, length, count and empty?, which OpenStruct does not define, read an
# OpenStruct's member (or nil) where one reaches the receiver, beside a
# class's own size and a container's: they answered the class's or the
# container's 0. A receiver no OpenStruct reaches keeps its Integer.
require "ostruct"

class Box
  def size = 3
  def length = 4
  def count = 5
  def empty? = false
end

[Box.new, OpenStruct.new(size: 9, length: 8, count: 7, empty?: true), OpenStruct.new].each do |x|
  p [x.size, x.length, x.count, x.empty?]
end

[[1, 2], OpenStruct.new(size: :big), "abc"].each { |x| p x.size }

# no OpenStruct reaches these: their sizes stay Integers
class Pair
  def size = 2
end
total = 0
[Box.new, Pair.new].each { |y| total += y.size }
p total
p [[1], [2, 3]].map { |z| z.size }.sum
