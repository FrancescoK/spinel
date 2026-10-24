# spinel: gc-stress
# A handle's access mode is checked before a write or a read: writing to
# a read-only handle and reading a write-only one raise IOError.
require "tmpdir"
def report(tag)
  p [tag, yield]
rescue => error
  p [tag, error.class, error.message]
end
path = File.join(Dir.tmpdir, "spinel_io_access_#{Process.pid}")
File.write(path, "abc\ndef\n")
begin
  f = File.open(path)
  begin
    report(:write) { f.write("x") }
    report(:print) { f.print("x") }
    report(:puts) { f.puts("x") }
    report(:shovel) { f << "x"; :ok }
    report(:printf) { f.printf("%d", 1) }
    report(:write_empty) { f.write("") }
    report(:puts_empty) { f.puts("") }
    report(:gets) { f.gets }
  ensure
    f.close
  end
  w = File.open(path, "w")
  begin
    report(:lineno) { w.lineno }
    report(:gets) { w.gets }
    report(:gets_sep) { w.gets(",") }
    report(:readline) { w.readline }
    report(:readlines) { w.readlines }
    report(:each_line) { w.each_line { |line| p line }; :ok }
    report(:pread) { w.pread(1, 0) }
    report(:write) { w.write("ab\n") }
  ensure
    w.close
  end
  a = File.open(path, "a")
  begin
    report(:append_gets) { a.gets }
  ensure
    a.close
  end
  rw = File.open(path, "r+")
  begin
    report(:rw_gets) { rw.gets }
    report(:rw_write) { rw.write("z") }
    report(:rw_lineno) { rw.lineno }
  ensure
    rw.close
  end
  report(:closed) { f.write("x") }
  r, pw = IO.pipe
  report(:pipe_read_end) { r.write("x") }
  report(:pipe_write_end) { pw.gets }
  pw.puts("p")
  pw.close
  report(:pipe_gets) { r.gets }
  r.close
ensure
  File.delete(path)
end
