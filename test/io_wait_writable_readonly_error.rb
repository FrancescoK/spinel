# spinel: gc-stress
require "tmpdir"
path = File.join(Dir.tmpdir, "spinel_wait_writable_#{Process.pid}.txt")
def t(tag)
  v = yield
  p [tag, v.class]
rescue => e
  p [tag, e.class, e.message]
end
begin
  File.write(path, "x")
  File.open(path) do |f|
    t(:read_only) { f.wait_writable(0) }
    t(:read_only_no_timeout) { f.wait_writable }
    t(:read_only_negative) { f.wait_writable(-1) }
    t(:wait_write_symbol) { f.wait(0, :write) }
    t(:wait_readable) { f.wait_readable(0) }
  end
  File.open(path, "r+") { |f| t(:read_write) { f.wait_writable(0) } }
  File.open(path, "a") { |f| t(:append) { f.wait_writable(0) } }
  File.open(path, "r:UTF-8") { |f| t(:read_only_encoding) { f.wait_writable(0) } }
  g = File.open(path)
  g.close
  t(:closed) { g.wait_writable(0) }
  r, w = IO.pipe
  t(:pipe_read_end) { r.wait_writable(0) }
  t(:pipe_write_end) { w.wait_writable(0) }
  r.close
  w.close
  io = [File.open(path), 1][0]
  t(:boxed_read_only) { io.wait_writable(0) }
  io.close
ensure
  File.delete(path) if File.exist?(path)
end
