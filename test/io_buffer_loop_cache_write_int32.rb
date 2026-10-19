# spinel: int64 -- assumes a 64-bit Integer (values or arithmetic past 2^31); not run on a 32-bit target
# io_buffer_loop_cache_write.rb's range checks: a 32-bit store takes
# [-2^31, 2^31-1] signed and [-2^31, 2^32-1] unsigned and raises CRuby's
# RangeError past them, inline and in a cached loop alike (where the writes
# before it went in); a 64-bit store takes any Integer that fits 64 bits.
# A write answers the offset just past its value, as CRuby's does.

def bytes(b)
  out = []
  i = 0
  while i < b.size
    out << b.get_value(:U8, i)
    i += 1
  end
  out.join(",")
end

def put(b, t, v)
  r = case t
  when :u32 then b.set_value(:u32, 0, v)
  when :s32 then b.set_value(:s32, 0, v)
  when :U32 then b.set_value(:U32, 0, v)
  when :S32 then b.set_value(:S32, 0, v)
  when :u64 then b.set_value(:u64, 0, v)
  when :s64 then b.set_value(:s64, 0, v)
  when :U64 then b.set_value(:U64, 0, v)
  when :S64 then b.set_value(:S64, 0, v)
  end
  "#{bytes(b)} -> #{r}"
rescue => e
  "#{e.class}: #{e.message}"
end

# a cached loop writing v - 2, v - 1, v at offsets 0, 4, 8
def ramp(t, b, v)
  i = 0
  last = 0
  case t
  when :u32 then while i < 3; last = b.set_value(:u32, i * 4, v - 2 + i); i += 1; end
  when :s32 then while i < 3; last = b.set_value(:s32, i * 4, v - 2 + i); i += 1; end
  when :U32 then while i < 3; last = b.set_value(:U32, i * 4, v - 2 + i); i += 1; end
  when :S32 then while i < 3; last = b.set_value(:S32, i * 4, v - 2 + i); i += 1; end
  end
  "ok -> #{last}; #{bytes(b)}"
rescue => e
  "at #{i}: #{e.class}: #{e.message}; #{bytes(b)}"
end

[:u32, :s32, :U32, :S32].each do |t|
  [2**31 - 1, 2**31, 2**32 - 1, 2**32, -2**31, -2**31 - 1].each do |v|
    puts "#{t} #{v}: #{put(IO::Buffer.new(4), t, v)}"
  end
  [2**31 - 1, 2**31 + 1, 2**32 - 1, 2**32 + 1, -2**31 + 2, -2**31 + 1].each do |v|
    puts "#{t} ramp to #{v}: #{ramp(t, IO::Buffer.new(12), v)}"
  end
end
[:u64, :s64, :U64, :S64].each do |t|
  [-1, 9_223_372_036_854_775_807, -9_223_372_036_854_775_808, 2**40 + 5].each do |v|
    puts "#{t} #{v}: #{put(IO::Buffer.new(8), t, v)}"
  end
end
