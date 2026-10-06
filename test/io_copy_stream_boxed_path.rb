# Boxed paths, including shared Strings, keep their path meaning in either
# endpoint. Streams keep their position, and invalid endpoints name read/write.
require "tmpdir"
require "stringio"

def copy_from(src)
  dst = StringIO.new
  p IO.copy_stream(src, dst)
  p dst.string.bytes
rescue => e
  p [e.class, e.message]
end

def copy_to(dst)
  p IO.copy_stream(StringIO.new("hello\0copy\n"), dst)
rescue => e
  p [e.class, e.message]
end

base = File.join(Dir.tmpdir, "spinel_copy_stream_boxed_#{Process.pid}")
src_path = base + ".src"
dst_path = base + ".dst"
File.binwrite(src_path, "hello\0copy\n")
begin
  src = src_path + ""
  src = 7 if ARGV.size > 5
  copy_from(src)

  shared_src = base.dup
  src_alias = shared_src
  shared_src << ".src"
  shared_src = 7 if ARGV.size > 5
  p src_alias == src_path
  copy_from(shared_src)

  File.open(src_path, "rb") do |io|
    io.read(2)
    copy_from(io)
  end
  sio = StringIO.new("hello\0copy\n")
  sio.read(2)
  copy_from(sio)

  dst = dst_path + ""
  dst = 7 if ARGV.size > 5
  copy_to(dst)
  p File.binread(dst_path).bytes

  shared_dst = base.dup
  dst_alias = shared_dst
  shared_dst << ".dst"
  shared_dst = 7 if ARGV.size > 5
  p dst_alias == dst_path
  copy_to(shared_dst)
  p File.binread(dst_path).bytes

  File.open(dst_path, "wb") do |io|
    io.write("prefix:")
    copy_to(io)
  end
  p File.binread(dst_path).bytes
  out = StringIO.new
  out.write("prefix:")
  copy_to(out)
  p out.string.bytes

  # A boxed path can also pair with a statically typed path or another box.
  p IO.copy_stream(src, dst_path)
  p File.binread(dst_path).bytes
  p IO.copy_stream(src_path, shared_dst)
  p File.binread(dst_path).bytes
  p IO.copy_stream(shared_src, dst)
  p File.binread(dst_path).bytes

  [nil, 7, true, :invalid, Object.new].each do |invalid|
    copy_from(invalid)
    copy_to(invalid)
  end
ensure
  File.delete(src_path)
  File.delete(dst_path) if File.exist?(dst_path)
end
