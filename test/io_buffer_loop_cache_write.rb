# A loop's literal-typed IO::Buffer set_values write into the bytes the loop
# keeps (the header cache), as its get_values read them: a value that goes
# within the buffer's writable bytes is stored there, and every other write
# takes the out-of-line path with its CRuby error -- a read-only buffer
# (AccessError, before the offset is looked at), an invalidated slice, nil,
# and offsets past both ends, after the writes that went in. A slice's
# writes reach its root; 8/16-bit stores wrap. The bytes are printed after
# each loop, with what the loop's last write answered (the offset just past
# its value, as CRuby's set_value does). The 32-bit range checks are
# io_buffer_loop_cache_write_int32.rb.
require "tmpdir"

def bytes(b)
  return "nil" unless b
  return "invalid" unless b.valid?
  out = []
  i = 0
  while i < b.size
    out << b.get_value(:U8, i)
    i += 1
  end
  out.join(",")
end

# A write to an invalidated slice says "Buffer is invalid!" (a read says
# "Buffer has been invalidated!").
def err(e)
  "#{e.class}: #{e.message}"
end

# one cached loop per type, writing from `from` up to `to`
def fill(t, b, from, to)
  i = from
  last = 0
  case t
  when :U8  then while i < to; last = b.set_value(:U8, i, (i * 37 + 11) % 100); i += 1; end
  when :S8  then while i < to; last = b.set_value(:S8, i, (i * 37 + 11) % 100 - 50); i += 1; end
  when :u16 then while i < to; last = b.set_value(:u16, i, (i * 37 + 11) % 100); i += 1; end
  when :s16 then while i < to; last = b.set_value(:s16, i, (i * 37 + 11) % 100 - 50); i += 1; end
  when :U16 then while i < to; last = b.set_value(:U16, i, (i * 37 + 11) % 100); i += 1; end
  when :S16 then while i < to; last = b.set_value(:S16, i, (i * 37 + 11) % 100 - 50); i += 1; end
  when :u32 then while i < to; last = b.set_value(:u32, i, (i * 37 + 11) % 100); i += 1; end
  when :s32 then while i < to; last = b.set_value(:s32, i, (i * 37 + 11) % 100 - 50); i += 1; end
  when :U32 then while i < to; last = b.set_value(:U32, i, (i * 37 + 11) % 100); i += 1; end
  when :S32 then while i < to; last = b.set_value(:S32, i, (i * 37 + 11) % 100 - 50); i += 1; end
  when :u64 then while i < to; last = b.set_value(:u64, i, (i * 37 + 11) % 100 - 50); i += 1; end
  when :s64 then while i < to; last = b.set_value(:s64, i, (i * 37 + 11) % 100 - 50); i += 1; end
  when :U64 then while i < to; last = b.set_value(:U64, i, (i * 37 + 11) % 100 - 50); i += 1; end
  when :S64 then while i < to; last = b.set_value(:S64, i, (i * 37 + 11) % 100 - 50); i += 1; end
  end
  "ok -> #{last}"
rescue => e
  "at #{i}: #{err(e)}"
end
def fillf(t, b, from, to)
  i = from
  last = 0
  case t
  when :f32 then while i < to; last = b.set_value(:f32, i, i * 0.25 - 1); i += 1; end
  when :f64 then while i < to; last = b.set_value(:f64, i, i * 0.25 - 1); i += 1; end
  when :F32 then while i < to; last = b.set_value(:F32, i, i * 0.25 - 1); i += 1; end
  when :F64 then while i < to; last = b.set_value(:F64, i, i * 0.25 - 1); i += 1; end
  end
  "ok -> #{last}"
rescue => e
  "at #{i}: #{err(e)}"
end
# read-modify-write: a cached read and a cached write of the same bytes
def bump(t, b)
  i = 0
  last = 0
  n = b.size
  case t
  when :U8  then while i < n; last = b.set_value(:U8, i, b.get_value(:U8, i) + 200); i += 1; end
  when :S8  then while i < n; last = b.set_value(:S8, i, b.get_value(:S8, i) + 100); i += 1; end
  when :U16 then while i < n - 1; last = b.set_value(:U16, i, b.get_value(:U16, i) + 60000); i += 2; end
  when :s16 then while i < n - 1; last = b.set_value(:s16, i, b.get_value(:s16, i) - 30000); i += 2; end
  when :u32 then while i < n - 3; last = b.set_value(:u32, i, b.get_value(:u32, i) % 1000); i += 4; end
  when :F64 then while i < n - 7; last = b.set_value(:F64, i, b.get_value(:F64, i) * 2); i += 8; end
  end
  "ok -> #{last}"
rescue => e
  "at #{i}: #{err(e)}"
end

def run(t, label, b, from, to)
  r = t.to_s.include?("f") || t.to_s.include?("F") ? fillf(t, b, from, to) : fill(t, b, from, to)
  puts "#{t} #{label} #{from}..#{to}: #{r}; #{bytes(b)}"
end

path = File.join(Dir.tmpdir, "sp_iob_loop_write_#{Process.pid}.bin")
File.binwrite(path, "\x00" * 16)

[:U8, :S8, :u16, :s16, :U16, :S16, :u32, :s32, :U32, :S32, :u64, :s64, :U64, :S64,
 :f32, :f64, :F32, :F64].each do |t|
  w = IO::Buffer.size_of(t)
  b = IO::Buffer.new(16)
  run(t, "owned", b, 0, 17 - w)
  run(t, "owned past the end", IO::Buffer.new(16), 12 - w, 20)
  run(t, "owned from -2", IO::Buffer.new(16), -2, 3)
  root = IO::Buffer.new(16)
  run(t, "slice", root.slice(3, 9), 0, 12)
  puts "#{t} its root: #{bytes(root)}"
  run(t, "zero", IO::Buffer.new(0), 0, 2)
  f = IO::Buffer.new(16)
  fs = f.slice(0, 8)
  f.free
  run(t, "freed", f, 0, 2)
  run(t, "slice of freed", fs, 0, 2)
  tr = IO::Buffer.new(16)
  u = tr.transfer
  run(t, "transferred from", tr, 0, 2)
  run(t, "transferred to", u, 0, 17 - w)
  r = IO::Buffer.new(16)
  rs = r.slice(8, 8)
  r.resize(4)
  run(t, "slice of shrunk", rs, 0, 2)
  run(t, "readonly", IO::Buffer.for("ABCDEFGHIJKLMNOP"), 0, 4)
  run(t, "readonly past the end", IO::Buffer.for("ABCDEFGH"), 7, 12)
  File.open(path) do |io|
    run(t, "mapped readonly", IO::Buffer.map(io, nil, 0, IO::Buffer::READONLY), 0, 4)
  end
  File.open(path, "r+") do |io|
    run(t, "mapped private", IO::Buffer.map(io, nil, 0, IO::Buffer::PRIVATE), 0, 17 - w)
  end
  run(t, "nil", nil, 0, 2)
end

[:U8, :S8, :U16, :s16, :u32, :F64].each do |t|
  b = IO::Buffer.new(16)
  fill(:U8, b, 0, 16)
  puts "#{t} bump: #{bump(t, b)}; #{bytes(b)}"
end

# two overlapping slices of one root: a write through one is read through
# the other in the same loop
root = IO::Buffer.new(16)
fill(:U8, root, 0, 16)
a = root.slice(0, 12)
c = root.slice(4, 12)
i = 0
while i < 8
  a.set_value(:U8, i + 4, c.get_value(:U8, i) + 1)
  i += 1
end
puts "overlap: #{bytes(root)}"
File.delete(path)
