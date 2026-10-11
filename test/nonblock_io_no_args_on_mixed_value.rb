# read_nonblock and write_nonblock with no arguments on a value that may be
# an IO raise CRuby's ArgumentError, and a Method taken by a computed name
# over such a value builds.
require "stringio"

r, w = IO.pipe
x = [w, 1][ARGV.size]
begin
  x.write_nonblock
rescue ArgumentError => e
  puts e.message
end
y = [r, 1][ARGV.size]
begin
  s = y.read_nonblock
  p s
rescue ArgumentError => e
  puts e.message
end
p x.write_nonblock("hi")
p y.read_nonblock(5)

class Res
  def name = "label"
  def label = "res"
end
def method_of(r, n) = r.method(n.to_sym)
recv = [Res.new, StringIO.new("ab")]
m = method_of(recv[ARGV.size], ["label", "read_nonblock"][ARGV.size])
p m.name
m = method_of(recv[1 - ARGV.size], ["label", "read_nonblock"][1 - ARGV.size])
p m.name
