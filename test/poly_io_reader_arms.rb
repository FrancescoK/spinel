# A parameter that receives both a File and a StringIO dispatches on the
# class id, and the IO arm covered only close, eof?, tell and a few more:
# getc, gets, readline, readlines, getbyte, lineno and sync raised
# NoMethodError for the File (putc is covered with StringIO's putc in
# stringio_readbyte_readchar_putc). Uses a temp file it deletes.
require "stringio"
require "tmpdir"

def read_some(io)
  p io.getc
  p io.gets
  p io.lineno
  p io.getbyte
  p io.readline
  p io.readlines
  p io.gets
  p io.getc
  p io.sync
end

path = File.join(Dir.tmpdir, "sp_poly_io_reader_arms_#{Process.pid}.txt")
File.write(path, "hello\nworld\nthree\nfour\n")
File.open(path) { |f| read_some(f) }
read_some(StringIO.new("hello\nworld\nthree\nfour\n"))
File.delete(path)
