require "tmpdir"

class TimeoutOwner
  attr_accessor :timeout
end

reader, writer = IO.pipe
owner = TimeoutOwner.new
[reader, owner].each do |object|
  p(object.timeout = 0.02)
  p object.timeout
  p object.public_send(:timeout=, 0.03).equal?(object)
end
reader.timeout = false
p reader.read(0)
begin
  reader.read(1)
rescue TypeError => error
  puts "#{error.class}: #{error.message}"
end
reader.timeout = 0.005
begin
  reader.read(1)
rescue IO::TimeoutError => error
  puts "#{error.class}: #{error.message}"
end
p reader.wait_readable
reader.timeout = nil
writer.write("OK")
p reader.wait_readable(0).inspect.start_with?("#<IO:fd ")
p reader.read(2)
writer.close
reader.timeout = 0.005
p reader.read(1)
reader.close

path = File.join(Dir.tmpdir, "spinel-io-timeout-#{Process.pid}")
begin
  File.binwrite(path, "abc\0def")
  File.open(path, "rb") do |io|
    io.timeout = Rational(1, 100)
    p io.read(3)
    p io.read(1).bytes
    p io.read
    p io.read(1)
    p io.read(0)
    io.rewind
    p io.read(1)
    p io.pos
    p io.getc
    p io.pos
    p io.read(1)
    p io.pos
    io.seek(0)
    p io.read(2)
    p io.pos
    p io.read
    p io.pos
  end
  stat = File.stat(path)
  begin
    stat.timeout
  rescue NoMethodError => error
    puts error.class
  end
  begin
    stat.timeout = 0.01
  rescue NoMethodError => error
    puts error.class
  end
ensure
  File.delete(path)
end
