require "logger"
require "stringio"
require "tmpdir"

io = StringIO.new
logger = Logger.new(io)
logger.close
puts "explicit close: #{io.closed?}"
logger.close
puts "repeated close: #{io.closed?}"

original = StringIO.new
replacement = StringIO.new
logger = Logger.new(original)
logger.reopen(replacement)
puts "original after reopen: #{original.closed?}"
logger.close
puts "replacement after close: #{replacement.closed?}"
original.close

path = File.join(Dir.tmpdir, "sp_logger_close_io_#{Process.pid}.log")
begin
  file = File.open(path, "w")
  logger = Logger.new(file)
  logger.close
  puts "received file after close: #{file.closed?}"

  original = StringIO.new
  logger = Logger.new(original)
  logger.reopen(path)
  puts "original after reopen to file: #{original.closed?}"
  logger.close
  original.close
ensure
  file.close if file && !file.closed?
  File.delete(path) if File.exist?(path)
end

class FailingCloseDevice
  def write(message)
    message.bytesize
  end

  def close
    raise IOError, "close failed"
  end
end

Logger.new(FailingCloseDevice.new).close
puts "close error ignored"
puts "no device: #{Logger.new(nil).close.inspect}"
