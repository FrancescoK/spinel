# IO.copy_stream / #rewind through a param that unions StringIO and File
# dispatch on the runtime stream class (#3257). Uses temp files it creates.
require 'stringio'

def send_to(dst, io)
  io.rewind
  IO.copy_stream(io, dst)
end

src_path = "/tmp/spinel_test_copy_stream_src_#{Process.pid}.txt"
dst_path = "/tmp/spinel_test_copy_stream_dst_#{Process.pid}.txt"
io1 = StringIO.new("hello-sio ")
io2 = File.open(src_path, "w+")
io2.write("hello-file")
dst = File.open(dst_path, "w")
send_to(dst, io1)
send_to(dst, io2)
dst.close
puts File.read(dst_path)
File.delete(src_path)
File.delete(dst_path)
