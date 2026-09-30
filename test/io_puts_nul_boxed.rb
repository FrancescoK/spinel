# puts on a File reached through a class-id dispatch (the parameter also
# receives a StringIO) went through sp_File_puts_val, which sized a String
# with strlen and dropped everything from an embedded NUL on. print on an
# IO with a boxed String did the same. Uses a temp file it deletes.
require "stringio"
require "tmpdir"

def emit(io)
  io.puts "a\0b"
  io.puts "c\0d", "e\0f"
  io.print "g\0h\n"
  io.write "i\0j\n"
end

path = File.join(Dir.tmpdir, "sp_io_puts_nul_boxed_#{Process.pid}.bin")
File.open(path, "w") { |f| emit(f) }
s = StringIO.new
emit(s)
p File.binread(path)
p s.string

v = [1, "k\0l"].last
File.open(path, "w") do |f|
  f.puts v
  f.print v, "\n"
  f.puts ["m\0n", ["o\0p"]]
end
p File.binread(path)
File.delete(path)
