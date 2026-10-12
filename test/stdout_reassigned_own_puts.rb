# A program that reassigns $stdout and has a puts of its own: a bare puts
# that reaches the program's method (on Kernel, in its class, or on an
# instance_eval block's receiver) still calls it, and the others write
# through $stdout.
require "stringio"
module Kernel
  def shout(a) = print("K:", a.upcase, "\n")
end
class W
  def puts(x) = STDOUT.write("W:#{x}\n")
  def go = puts("own")
end
io = StringIO.new
$stdout = io
puts "cap"
W.new.go
W.new.instance_eval { puts "ie" }
shout "s"
$stdout = STDOUT
p io.string
