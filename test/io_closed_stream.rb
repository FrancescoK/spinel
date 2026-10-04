# Every operation on a closed handle raises IOError, as in CRuby: the byte and
# character readers, the flag accessors, the descriptor queries and the
# positioning calls used to answer nil, EOF, false or a default instead.
# #closed?, #close, #inspect and #path keep working on a closed handle. The
# loops that read a handle keep it rooted for their whole run, and the sync
# accessors evaluate their receiver once.

require "io/console"
require "socket"

# The scratch paths carry the process id, so that two runs at once do not
# share them; the lines printed name them without it.
def try(label)
  r = yield
  puts "#{label} => #{r.inspect.gsub("_#{Process.pid}", "")}"
rescue IOError, EOFError => e
  puts "#{label}: #{e.class}: #{e.message.gsub("_#{Process.pid}", "")}"
end

path = "/tmp/sp_io_closed_stream_#{Process.pid}.txt"
lines_path = "/tmp/sp_io_closed_stream_lines_#{Process.pid}.txt"
dir = "/tmp/sp_io_closed_stream_dir_#{Process.pid}"
if Dir.exist?(dir)
  Dir.children(dir).each { |e| File.delete("#{dir}/#{e}") }
  Dir.rmdir(dir)
end
Dir.mkdir(dir)
3.times { |i| File.write("#{dir}/f#{i}", "") }
# a wider directory for the temporary-receiver loops: master only loses the
# handle once the sweep runs, which a three-entry listing never reaches
bigdir = "/tmp/sp_io_closed_stream_bigdir_#{Process.pid}"
if Dir.exist?(bigdir)
  Dir.children(bigdir).each { |e| File.delete("#{bigdir}/#{e}") }
  Dir.rmdir(bigdir)
end
Dir.mkdir(bigdir)
20.times { |i| File.write("#{bigdir}/g#{i}", "") }
File.write(path, "abc\ndef\n")
File.write(lines_path, (1..200).map { |i| "line #{i}" }.join("\n") + "\n")

io = File.open(path, "r+")
io.close

puts "--- still answering"
try("closed?") { io.closed? }
try("close") { io.close }
try("inspect") { io.inspect }
try("path") { io.path }
try("to_path") { io.to_path }

puts "--- readers"
try("eof?") { io.eof? }
try("read") { io.read }
try("read(1)") { io.read(1) }
try("readpartial") { io.readpartial(1) }
try("sysread") { io.sysread(1) }
try("pread") { io.pread(1, 0) }
try("gets") { io.gets }
try("gets(sep)") { io.gets("e") }
try("readline") { io.readline }
try("readlines") { io.readlines }
try("each_line") { io.each_line { |l| puts l } }
try("getc") { io.getc }
try("readchar") { io.readchar }
try("getbyte") { io.getbyte }
try("readbyte") { io.readbyte }
try("ungetc") { io.ungetc("x") }
try("ungetbyte") { io.ungetbyte(120) }
try("each_byte") { io.each_byte { |b| puts b } }
try("each_char") { io.each_char { |c| puts c } }
try("each_codepoint") { io.each_codepoint { |c| puts c } }

puts "--- writers"
try("write") { io.write("x") }
try("puts") { io.puts("x") }
try("print") { io.print("x") }
try("<<") { io << "x" }
try("putc") { io.putc("x") }
try("syswrite") { io.syswrite("x") }
try("pwrite") { io.pwrite("x", 0) }
try("flush") { io.flush }
try("fsync") { io.fsync }
try("fdatasync") { io.fdatasync }

puts "--- position"
try("pos") { io.pos }
try("tell") { io.tell }
try("pos=") { io.pos = 0 }
try("seek") { io.seek(0) }
try("sysseek") { io.sysseek(0) }
try("rewind") { io.rewind }
try("lineno") { io.lineno }
try("lineno=") { io.lineno = 3 }

puts "--- flags and descriptor"
try("sync") { io.sync }
try("sync=") { io.sync = true }
try("autoclose?") { io.autoclose? }
try("autoclose=") { io.autoclose = false }
try("close_on_exec?") { io.close_on_exec? }
try("close_on_exec=") { io.close_on_exec = true }
try("binmode") { io.binmode }
try("binmode?") { io.binmode? }
try("tty?") { io.tty? }
try("isatty") { io.isatty }
try("fileno") { io.fileno }
try("to_i") { io.to_i }
try("stat") { io.stat }
try("flock") { io.flock(0) }
try("advise") { io.advise(:normal) }
try("fcntl") { io.fcntl(1) }
try("wait_readable") { io.wait_readable(0) }
try("wait_writable") { io.wait_writable(0) }
try("wait") { io.wait(0, :read) }
try("winsize") { io.winsize }

puts "--- a pipe end read back out of its pair"
r, w = IO.pipe
r.close
w.close
try("pipe sync") { r.sync }
try("pipe sync=") { r.sync = false }
try("pipe gets") { r.gets }
try("pipe write") { w.write("x") }
try("pipe closed?") { [r.closed?, w.closed?] }

puts "--- an open handle keeps its answers"
io = File.open(path)
try("open lineno") { io.lineno }
try("open gets") { io.gets }
try("open lineno after gets") { io.lineno }
try("open lineno=") { io.lineno = 7 }
try("open sync") { io.sync }
try("open sync=") { io.sync = true }
try("open autoclose?") { io.autoclose? }
try("open autoclose=") { io.autoclose = true }
try("open getbyte") { io.getbyte }
try("open eof? at end") { io.read; io.eof? }
try("open getc at end") { io.getc }
try("open getbyte at end") { io.getbyte }
try("open readbyte at end") { io.readbyte }
io.close

puts "--- a temporary receiver keeps its handle for the whole loop"
n = 0
File.open(lines_path).each_line { |l| 100.times { "x" * 64 }; n += 1 }
puts "each_line on a temporary receiver saw #{n} lines"
n = 0
File.new(lines_path).each_byte { |b| 20.times { "y" * 64 }; n += 1 }
puts "each_byte on a temporary receiver saw #{n} bytes"
n = 0
File.open(lines_path).each_char { |c| 20.times { "z" * 64 }; n += 1 }
puts "each_char on a temporary receiver saw #{n} chars"
n = 0
File.open(lines_path).each_codepoint { |c| 20.times { "v" * 64 }; n += 1 }
puts "each_codepoint on a temporary receiver saw #{n} codepoints"
n = 0
Dir.open(bigdir).each { |e| 100.times { "w" * 64 }; n += 1 }
puts "Dir#each on a temporary receiver saw #{n} entries"
n = 0
Dir.open(bigdir).each_child { |e| 100.times { "u" * 64 }; n += 1 }
puts "Dir#each_child on a temporary receiver saw #{n} children"

puts "--- sync and sync= evaluate their receiver once"
$count = 0
$handle = File.open(lines_path)
def handle
  $count += 1
  $handle
end
handle.sync
puts "sync evaluated its receiver #{$count} time(s)"
$count = 0
handle.sync = true
puts "sync= evaluated its receiver #{$count} time(s)"
$handle.close

puts "--- a closed socket"
srv = TCPServer.new("127.0.0.1", 0)
port = srv.addr[1]
c = TCPSocket.new("127.0.0.1", port)
s = srv.accept
c.close
srv.close
try("socket addr") { c.addr }
try("socket peeraddr") { c.peeraddr }
try("server addr") { srv.addr }
s.close

puts "--- Dir"
d = Dir.open(dir)
d.close
try("dir close") { d.close }
try("dir path") { d.path }
try("dir inspect") { d.inspect }
try("dir read") { d.read }
try("dir rewind") { d.rewind }
try("dir tell") { d.tell }
try("dir pos") { d.pos }
try("dir seek") { d.seek(0) }
try("dir pos=") { d.pos = 0 }
try("dir fileno") { d.fileno }
try("dir each") { d.each { |e| puts e } }
try("dir each_child") { d.each_child { |e| puts e } }
try("dir children") { d.children }
try("dir entries") { d.entries }

File.delete(path)
File.delete(lines_path)
Dir.children(bigdir).each { |e| File.delete("#{bigdir}/#{e}") }
Dir.rmdir(bigdir)
Dir.children(dir).each { |e| File.delete("#{dir}/#{e}") }
Dir.rmdir(dir)
