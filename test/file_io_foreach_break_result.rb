# spinel: gc-stress
require "tmpdir"
path = File.join(Dir.tmpdir, "spinel_foreach_break_#{Process.pid}.txt")
File.write(path, "a\nb\n")
begin
  p File.foreach(path) { |_line| break :found }
  p IO.foreach(path) { |_line| break :found }
  p File.foreach(path) { |line| break line if line == "b\n" }
  p File.foreach(path) { |line| break line if line == "z\n" }
  p File.foreach(path, chomp: true) { |line| break [line, 1] }
  p File.foreach(path, encoding: "UTF-8") { |line| break line.upcase if line == "b\n" }
  p IO.foreach(path, mode: "r") { |line| break line }
  p File.foreach(path, encoding: "UTF-8") { |line| break line if line == "z\n" }
ensure
  File.delete(path)
end
