# In a program with an identity Set, a boxed value the analysis cannot tell
# from a Set may still be an Integer: `bits & 0xFF` there is no Set's `&`
# (a Set raises ArgumentError for an operand that is no collection, before
# anything enters it), and `(bits >> 32) + x` is no Set's `+` (no Set
# answers `>>`), so neither is refused. The packed value comes from a
# computed name, which no class fact follows.
require 'set'

class Location
  def initialize(start, length) = (@start = start; @length = length)
  attr_reader :start, :length
end

class Node
  def initialize(location) = @location = location

  def location
    location = @location
    return location if location.is_a?(Location)
    @location = Location.new(location >> 32, location & 0xFFFFFFFF)
  end

  def flags = @location.is_a?(Location) ? 0 : (@location | 1) ^ 2

  def end_offset
    location = @location
    location.is_a?(Location) ? 99 : ((location >> 32) + (location & 0xFFFFFFFF))
  end
end

def packed(name) = send(name)
def bits = (5 << 32) | 7

seen = Set.new.compare_by_identity
n = Node.new(packed(:bits))
seen << n
p n.flags, n.end_offset
p n.location.start, n.location.length, seen.include?(n), seen.include?(Node.new(1))
begin
  Set[:a] & 5
rescue ArgumentError => e
  p e.message
end
