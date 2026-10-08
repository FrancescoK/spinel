# spinel: int64
# -2**63 is the word of the nil sentinel of a nullable Integer slot, but an
# Integer that no nil can reach is not tested for it: a local written only
# literals and the results of arithmetic and bitwise operators is that number.
# Printed, interpolated, converted, asked a predicate or used as a condition it
# answers as CRuby does (a bitboard's top square, ~INT64_MAX; #7612).
n = ARGV.size
v = ~(0x7fffffffffffffff - n)
w = -9223372036854775807 - (n + 1)
[v, w].each_with_index do |_, k|
  x = k == 0 ? v : w
  p x
  puts x
  puts "#{x}"
  puts x.to_s
  p x.inspect
  p x.nil?
  p(x ? 1 : 2)
  p x == 0
  p x.zero?
  p x.even?
  p x.odd?
  p x.positive?
  p x.negative?
  p x.to_f
  p x.to_i
  p(x || 8)
  p(x && 7)
  i = 0
  while x && i < 2
    i += 1
  end
  p i
end
y = v
p y
z = (v | 0)
puts z
