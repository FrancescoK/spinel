# set_value with a literal type symbol writes inline (sp_IOBuffer_store_i/_f):
# a writable owned buffer, an in-range offset and a value the type holds
# store directly, and every other case -- a read-only buffer (before its
# offset is looked at), a slice, a freed, transferred or shrunk root, a
# negative or edge offset -- falls back to the out-of-line write with its
# CRuby errors. 8/16-bit stores wrap. Each `when` below is its own
# literal-symbol call site, with an Integer (put, putfi) or a Float (putf)
# value; the bytes are printed after every write.
require "tmpdir"

def put(b, t, o, v)
  case t
  when :U8  then b.set_value(:U8, o, v)
  when :S8  then b.set_value(:S8, o, v)
  when :u16 then b.set_value(:u16, o, v)
  when :s16 then b.set_value(:s16, o, v)
  when :U16 then b.set_value(:U16, o, v)
  when :S16 then b.set_value(:S16, o, v)
  when :u32 then b.set_value(:u32, o, v)
  when :s32 then b.set_value(:s32, o, v)
  when :U32 then b.set_value(:U32, o, v)
  when :S32 then b.set_value(:S32, o, v)
  when :u64 then b.set_value(:u64, o, v)
  when :s64 then b.set_value(:s64, o, v)
  when :U64 then b.set_value(:U64, o, v)
  when :S64 then b.set_value(:S64, o, v)
  end
end

def putf(b, t, o, v)
  case t
  when :f32 then b.set_value(:f32, o, v)
  when :f64 then b.set_value(:f64, o, v)
  when :F32 then b.set_value(:F32, o, v)
  when :F64 then b.set_value(:F64, o, v)
  end
end

# an Integer into a float type
def putfi(b, t, o, v)
  case t
  when :f32 then b.set_value(:f32, o, v)
  when :F64 then b.set_value(:F64, o, v)
  end
end

def bytes(b)
  out = []
  i = 0
  while i < b.size
    out << b.get_value(:U8, i)
    i += 1
  end
  out.join(",")
end

# A write to an invalidated slice prints its class only: Spinel's message
# for it is the read's ("Buffer has been invalidated!"), where CRuby's
# writes say "Buffer is invalid!".
def report(label, b, e)
  if e
    msg = e.is_a?(IO::Buffer::InvalidatedError) ? "" : ": #{e.message}"
    puts "#{label}: #{e.class}#{msg}"
  else
    puts "#{label}: #{bytes(b)}"
  end
end

def probe(t, label, b, offs, iv, fv)
  offs.each do |o|
    e = nil
    begin
      if t.to_s.include?("f") || t.to_s.include?("F")
        putf(b, t, o, fv)
      else
        put(b, t, o, iv)
      end
    rescue => x
      e = x
    end
    report("#{t} #{label} #{o}", b, e)
  end
end

def probe_fi(t, label, b, o, iv)
  e = nil
  begin
    putfi(b, t, o, iv)
  rescue => x
    e = x
  end
  report("#{t} #{label} #{o} #{iv}", b, e)
end

path = File.join(Dir.tmpdir, "sp_iob_set_inline_#{Process.pid}.bin")
File.binwrite(path, "\x00" * 16)

[:U8, :S8, :u16, :s16, :U16, :S16, :u32, :s32, :U32, :S32, :u64, :s64, :U64, :S64,
 :f32, :f64, :F32, :F64].each do |t|
  w = IO::Buffer.size_of(t)
  b = IO::Buffer.new(16)
  probe(t, "owned", b, [0, 1, 16 - w, 17 - w, 16, -1, 2**30, -(2**30)], -2, -2.5)
  probe(t, "small", b, [0], 5, 5.25)
  probe(t, "slice", b.slice(3, 9), [0, 9 - w, 10 - w, -1], -2, -2.5)
  puts "#{t} root after slice writes: #{bytes(b)}"
  probe(t, "zero", IO::Buffer.new(0), [0], -2, -2.5)
  probe(t, "short", IO::Buffer.new(w - 1), [0], -2, -2.5)
  f = IO::Buffer.new(16)
  fs = f.slice(0, 8)
  f.free
  probe(t, "freed", f, [0], -2, -2.5)
  probe(t, "slice-of-freed", fs, [0], -2, -2.5)
  tr = IO::Buffer.new(16)
  u = tr.transfer
  probe(t, "transferred-from", tr, [0], -2, -2.5)
  probe(t, "transferred-to", u, [16 - w], -2, -2.5)
  r = IO::Buffer.new(16)
  rs = r.slice(8, 8)
  r.resize(4)
  probe(t, "slice-of-shrunk", rs, [0], -2, -2.5)
  probe(t, "shrunk", r, [0, 4 - w, 5 - w], -2, -2.5)
  ro = IO::Buffer.for("ABCDEFGHIJKLMNOP")
  probe(t, "readonly", ro, [0, 16, -1], -2, -2.5)
  probe(t, "readonly-slice", ro.slice(2, 8), [0], -2, -2.5)
  File.open(path) do |io|
    probe(t, "mapped-readonly", IO::Buffer.map(io, nil, 0, IO::Buffer::READONLY), [0, 16], -2, -2.5)
  end
  File.open(path, "r+") do |io|
    probe(t, "mapped-private", IO::Buffer.map(io, nil, 0, IO::Buffer::PRIVATE), [0, 17 - w], -2, -2.5)
  end
end

# 8/16-bit stores wrap; 32-bit ones take values within range
b = IO::Buffer.new(8)
probe(:U8, "value 256", b, [0], 256, 0.0)
probe(:U8, "value -1", b, [0], -1, 0.0)
probe(:S8, "value 200", b, [0], 200, 0.0)
probe(:S8, "value -129", b, [0], -129, 0.0)
probe(:u16, "value 70000", b, [0], 70000, 0.0)
probe(:S16, "value -40000", b, [0], -40000, 0.0)
probe(:U16, "value 65535", b, [0], 65535, 0.0)
probe(:u32, "value 1000000000", b, [0], 1_000_000_000, 0.0)
probe(:S32, "value -1000000000", b, [0], -1_000_000_000, 0.0)
probe(:U32, "value 7", b, [0], 7, 0.0)
probe(:s32, "value 0", b, [0], 0, 0.0)
# a float type takes an Integer; the infinities are stored as such
probe_fi(:f32, "int", b, 0, 3)
probe_fi(:F64, "int", b, 0, -7)
probe(:f64, "inf", b, [0], 0, Float::INFINITY)
probe(:F32, "-inf", b, [0], 0, -Float::INFINITY)
nb = IO::Buffer.new(8)
nb.set_value(:f64, 0, Float::NAN)
puts "f64 nan: #{nb.get_value(:f64, 0).nan?}"
File.delete(path)
