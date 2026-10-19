# spinel: int64 -- u64/s64 values past 2^31
# io_buffer_write_answers.rb's answers for 64-bit values past a 32-bit
# Integer: set_value answers the offset just past the value, through the
# typed setter (an Integer), the boxed one (a Float or a Bignum beside it)
# and the generic entry (a type known only at run time), and set_values
# chains it.

b = IO::Buffer.new(32)
puts b.set_value(:u64, 8, 1 << 40)
puts b.set_value(:S64, 24, -(1 << 40))
puts b.set_value(:s64, 0, 9_223_372_036_854_775_807)
puts b.set_value(:U64, 16, -9_223_372_036_854_775_808)
[1 << 40, 2.5, 2**63, 2**64 - 1].each_with_index { |v, i| puts b.set_value(:u64, 8 * i, v) }
[:u64, :S64].each { |t| puts "#{t} #{b.set_value(t, 3, 1 << 40)}" }
puts b.set_values([:u64, :s64, :U8], 4, [2**63, -(1 << 40), 1])
puts b.get_values([:u64, :s64, :U8], 4).inspect
