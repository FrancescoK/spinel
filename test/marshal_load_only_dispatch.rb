# A program that only loads with Marshal answers as CRuby's does, an object
# of one of its classes included. The per-class half of the object dispatch
# no call reaches, the dump's, is left out: a program of many classes
# carried it for a Marshal.load of plain data.

class Point
  attr_accessor :x, :y
  def initialize(x, y) = (@x = x; @y = y)
end

blob = "\x04\b[\bi\x06I\"\x06a\x06:\x06ET{\x06:\x06bi\a".b
p Marshal.load(blob)
pt = Marshal.load("\x04\bo:\nPoint\a:\a@xi\x06:\a@yI\"\btwo\x06:\x06ET".b)
p pt.class, pt.x, pt.y
q = Point.new(3, "four")
q.x += 1
p q.x, q.y
