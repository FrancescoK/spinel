# spinel: gc-stress
# IO#pread with a negative offset raises the native Errno class: a File's
# message names rb_io_pread and its path; a pipe has no path, so the bare
# message. A handle not open for reading is IOError, checked before the
# syscall; a length of 0 answers "" before any check.
require "tmpdir"
path = File.join(Dir.tmpdir, "spinel_pread_offset_#{Process.pid}.txt")
File.write(path, "abc")
f = File.open(path)
begin
  p f.pread(2, -1)
rescue => e
  p [e.class, e.message.sub(path, "<path>")]
end
begin
  buf = +""
  p f.pread(2, -1, buf)
rescue SystemCallError => e
  p [e.class, e.errno == Errno::EINVAL::Errno]
end
p f.pread(2, 1)
p f.pread(0, -1)
p f.pread(0, 100)
f.close
p f.pread(0, 0)
begin
  f.pread(1, 0)
rescue IOError => e
  p [e.class, e.message]
end

["w", "a"].each do |mode|
  w = File.open(path, mode)
  begin
    w.pread(2, 0)
  rescue IOError => e
    p [mode, e.class, e.message]
  end
  p [mode, w.pread(0, 0), w.pread(0, -1)]
  w.close
end
File.open(path, "w+") do |rw|
  rw.write("xyz")
  rw.flush
  p rw.pread(2, 1)
end
File.delete(path)

r, w = IO.pipe
begin
  p r.pread(2, 0)
rescue => e
  p [e.class, e.message]
end
p r.pread(0, 0)
begin
  w.pread(2, 0)
rescue IOError => e
  p [e.class, e.message]
end
p w.pread(0, 0)
r.close
w.close
