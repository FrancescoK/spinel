# IO#dup and #clone make a new handle on a dup(2) of the descriptor, as
# CRuby does. They handed back the same handle, so the usual way to put
# stdout back after a #reopen -- keep `$stdout.dup`, reopen it at the end,
# close the copy -- left the output going to the file and then closed
# stdout itself.
require "tmpdir"
path = File.join(Dir.tmpdir, "spinel_io_dup_#{Process.pid}.txt")

out = File.open(path, "w+")
orig = $stdout.dup
p orig.equal?($stdout), orig.fileno == $stdout.fileno
$stdout.reopen(out)
puts "captured"
$stdout.flush
$stdout.reopen(orig)
orig.close
puts "back on stdout"
out.rewind
p out.read
out.close

# the copy shares the file position, and closing one leaves the other open
f = File.open(path, "w")
f.write "abc\n"
g = f.dup
p g.class, g.path == path
g.write "def\n"
f.close
p g.closed?, f.closed?
g.close
p File.read(path)
p (f.dup rescue [$!.class, $!.message])

# a pipe's write end survives the original's close through its copy
r, w = IO.pipe
w2 = w.clone
w.close
w2.write "via the copy"
w2.close
p r.read
r.close

# an append handle's copy appends too
File.write(path, "abc\ndef\nghi\n")
h = File.open(path, "a")
h2 = h.dup
h2.write "jkl\n"
h2.close
h.close
p File.read(path).lines.size

# a boxed IO copies the same way
x = [1, $stdout].last
y = x.dup
p y.equal?($stdout)
y.puts "through the boxed copy"
y.close
puts "stdout still open"

# $stderr's copy writes at once, as $stderr does
e = $stderr.dup
p e.sync
e.close

# a File::Stat has no descriptor and copies as before
st = File.stat(Dir.tmpdir)
p st.dup.directory?
File.delete(path)

# Buffered output that cannot be written fails the dup
if File.exist?("/dev/full")
  full = File.open("/dev/full", "w")
  full.write("x" * 10)
  begin
    full.dup
    puts "full dup: ok"
  rescue SystemCallError => e
    puts "full dup: #{e.class}"
  end
else
  puts "full dup: Errno::ENOSPC"
end
