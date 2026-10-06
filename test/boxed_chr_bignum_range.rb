# spinel: int64
# chr on a boxed Bignum: past any character, CRuby's RangeError, where it
# answered the first character of the number's digits.

v = [2**70, 1][ARGV.size]
begin
  p v.chr
rescue RangeError => e
  puts "#{e.class}: #{e.message}"
end
w = [65, 2**70][ARGV.size]
p w.chr
