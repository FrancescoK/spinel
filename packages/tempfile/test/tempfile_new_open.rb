require "tempfile"

# Tempfile.open with a block: the file is open for reading and writing,
# closed after the block, and kept until the program exits.
kept = nil
r = Tempfile.open("tmp") do |f|
  kept = f.path
  f.puts %w[test -x --seed 24]
  f.flush
  f.rewind
  p f.read
  f.rewind
  p f.gets
  p f.gets(chomp: true)
  p f.readlines
  f.rewind
  f.each_line { |l| p l }
  p f.size
  f.write("a", "b")
  p f.pos
  f.seek(0)
  p f.read(4)
  p f.eof?
  :blockval
end
p r
p File.exist?(kept)
p File.basename(kept).start_with?("tmp")

# Tempfile.new: $stdout redirected into it and back.
t = Tempfile.new("out")
p t.closed?
orig = $stdout.dup
$stdout.reopen t
puts "captured"
$stdout.flush
$stdout.reopen orig
t.rewind
p t.read
pa = t.path
t.close!
p File.exist?(pa), t.path

# unlink keeps the file open; path is nil after it.
u = Tempfile.new(["img", ".png"])
p File.extname(u.path)
u.write("xyz")
u.unlink
p u.path
u.rewind
p u.read
u.close

# close then open again: content kept, from the start.
o = Tempfile.new("re")
o.print "abc"
o.close
p o.closed?
p o.size
o.open
p o.read
o << "d"
o.rewind
p o.getc, o.readchar, o.getbyte
o.close(true)

# a Tempfile without a block answers itself from open
q = Tempfile.open("noblk")
p q.class
q.close!

# unlink and close! answer true; size counts what is still buffered;
# open keeps binmode; inspect names the subclass
t2 = Tempfile.new("a")
p t2.unlink, t2.unlink
p Tempfile.new("b").close!
b = Tempfile.new("c", binmode: true)
b.close
b.open
p b.binmode?
b.write("abc")
p b.size
b.close!
class MyTmp < Tempfile; end
m = MyTmp.new("s")
p m.inspect.start_with?("#<MyTmp:")
m.close!

# left to the exit sweep
$leak = Tempfile.new("leak").path
at_exit { p File.exist?($leak) }
