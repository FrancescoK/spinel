# File.open's block parameter, and an IO loop's, captured by a real proc
# (a method taking &block with an early return, so not inlined): the proc
# read the variable's cell, which nothing had written.
require "tmpdir"
def tx(&block)
  return true if block.nil?
  block.call
end
path = File.join(Dir.tmpdir, "spinel_param_captured_#{Process.pid}.txt")
File.write(path, "a\nb\n")
File.open(path, "rb") do |io|
  tx { io.each_line { |l| p l } }
end
File.open(path) do |io|
  io.each_line { |l| tx { p l } }
end
io = File.open(path)
io.each_char { |ch| tx { print ch } }
io.close
puts
p tx
File.delete(path)
