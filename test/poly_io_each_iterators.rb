require "stringio"

def lines(io) = io.each_line { |l| p l }
def chars(io) = io.each_char { |c| p c }
def bytes(io) = io.each_byte { |b| p b }

def all(io)
  io.each_line { |l| p [:line, l] }
  io.rewind
  io.each_char { |c| p [:char, c] }
  io.rewind
  io.each_byte { |b| p [:byte, b] }
  io.rewind
end

path = "/tmp/spinel_poly_io_each_iterators_#{Process.pid}.txt"
File.write(path, "a\nb\n")
File.open(path) do |f|
  all(f)
  r = lines(f)
  p r.equal?(f)
  f.rewind
  chars(f)
  f.rewind
  bytes(f)
end

s = StringIO.new("x\ny\n")
all(s)
r = lines(s)
p r.equal?(s)
s.rewind
chars(s)
s.rewind
bytes(s)
