# A reader's String stored into a container is refused when the element is
# changed in place and the ivar behind the reader is no shared handle
# (test/reject/reader_string_elem_append.rb). These neighbours still
# compile: a reader's String stored and only read, and one whose ivar is
# already the shared handle because the program appends through an alias
# of the reader.

class Box
  def initialize = (@s = +"q")

  attr_reader :s

  def text = @s
end

k = Box.new
a = []
a << k.s
a.push(k.text)
h = { s: k.s }
p a, h, k.s, a[0] == h[:s]

m = Box.new
x = m.s
x << "?"
b = []
b << m.s
b[0] << "!"
c = {}
c[:t] = m.text
c[:t].concat("#")
p m.s, b, c
