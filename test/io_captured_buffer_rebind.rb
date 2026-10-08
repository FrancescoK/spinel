# An IO read that fills a buffer argument (read, readpartial, pread,
# read_nonblock) rebinds the buffer local to the bytes read. A local a
# proc captures lives in a cell, and the rebind spelled it lv_<name>,
# which nothing declares, so the C did not compile.
# spinel: share
require "tmpdir"

path = File.join(Dir.tmpdir, "spinel_io_captured_buffer_#{Process.pid}.txt")
File.write(path, "hello world")

def typed_reads(path, n)
  buf = +""
  g = -> { buf } if n == 9123
  File.open(path) do |f|
    f.readpartial(5, buf)
    p buf
    f.read(3, buf)
    p buf
    p f.pread(4, 6, buf), buf
    p f.read_nonblock(2, buf), buf
  end
  p g
end
typed_reads(path, ARGV.size)

# the proc reads the buffer after the reads
def called_later(path)
  buf = +""
  g = -> { buf.size }
  File.open(path) do |f|
    f.readpartial(4, buf)
    p g.call
    f.pread(2, 0, buf)
    p g.call, buf
  end
end
called_later(path)

# a receiver that is an IO or an Integer: the boxed IO arms
def boxed_reads(path, n)
  buf = +""
  g = -> { buf } if n == 9123
  f = [File.open(path), 1][n]
  f.readpartial(3, buf)
  p buf
  f.pread(2, 9, buf)
  p buf
  f.close
  p g
end
boxed_reads(path, ARGV.size)

File.delete(path)
