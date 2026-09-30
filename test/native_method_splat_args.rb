require "stringio"

def t(label)
  r = yield
  p [label, r]
rescue ArgumentError => e
  p [label, e.class, e.message]
end

arr = %w[p q]
none = []
s = StringIO.new
s.print(*arr)
s.puts(*arr)
s.puts(*none)
s.print(*none)
s.print("a", *arr, "z")
s.puts(1, *[2, 3], 4, 5)
t(:write) { s.write(*arr, 7) }
p s.string

r = StringIO.new("hello\nworld\n")
t(:seek) { r.seek(*[2]) }
t(:read) { r.read(*[3]) }
t(:seek3) { r.seek(*[1, 2, 3]) }
t(:gets) { r.gets(*["o"]) }
t(:gets0) { r.gets(*none) }
t(:getc1) { r.getc(*[1]) }

args = ["abc"]
n = StringIO.new(*args)
p n.read
t(:new3) { StringIO.new(*["a", "r", 3]) }
