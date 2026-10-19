# spinel: int64 -- assumes a 64-bit Integer (values or arithmetic past 2^31); not run on a 32-bit target
# io_buffer_loop_cache.rb for the 32-bit integer types: a loop keeps the
# buffer's bytes and reads each type there, its width, byte order and sign
# included, over every kind of buffer and past both ends. (On a 32-bit
# target these types read boxed and no loop caches them.)
require "tmpdir"

def fill(b)
  i = 0
  while i < b.size
    b.set_value(:U8, i, (i * 73 + 129) % 256)
    i += 1
  end
  b
end

# one cached loop per type, from `from` up to `to`, summing what it reads
def scan(t, b, from, to)
  s = 0
  i = from
  case t
  when :u32 then while i < to; s += b.get_value(:u32, i); i += 1; end
  when :s32 then while i < to; s += b.get_value(:s32, i); i += 1; end
  when :U32 then while i < to; s += b.get_value(:U32, i); i += 1; end
  when :S32 then while i < to; s += b.get_value(:S32, i); i += 1; end
  end
  "#{s}"
rescue => e
  "#{s} then at #{i}: #{e.class}: #{e.message}"
end
def run(t, label, b)
  n = b ? b.size : 3
  [[0, n], [-1, n], [0, n + 1]].each do |from, to|
    r = scan(t, b, from, to)
    puts "#{t} #{label} #{from}...#{to}: #{r}"
  end
end

path = File.join(Dir.tmpdir, "sp_iob_loop_cache_int32_#{Process.pid}.bin")
File.binwrite(path, (0...16).map { |i| ((i * 73 + 129) % 256).chr }.join)

[:u32, :s32, :U32, :S32].each do |t|
  w = IO::Buffer.size_of(t)
  b = fill(IO::Buffer.new(16))
  run(t, "owned", b)
  run(t, "slice", b.slice(3, 9))
  run(t, "zero", IO::Buffer.new(0))
  run(t, "short", fill(IO::Buffer.new(w - 1)))
  f = fill(IO::Buffer.new(16))
  fs = f.slice(0, 8)
  f.free
  run(t, "freed", f)
  run(t, "slice-of-freed", fs)
  tr = fill(IO::Buffer.new(16))
  u = tr.transfer
  run(t, "transferred-from", tr)
  run(t, "transferred-to", u)
  r = fill(IO::Buffer.new(16))
  rs = r.slice(8, 8)
  r.resize(4)
  run(t, "slice-of-shrunk", rs)
  run(t, "shrunk", r)
  File.open(path) do |io|
    run(t, "mapped", IO::Buffer.map(io, nil, 0, IO::Buffer::READONLY))
  end
  run(t, "for", IO::Buffer.for("ABCDEFGHIJ"))
end
File.delete(path)
