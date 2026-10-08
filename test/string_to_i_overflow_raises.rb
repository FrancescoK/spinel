# spinel: not-cruby
# String#to_i / Integer() on input exceeding int64 raises
# RangeError rather than saturating silently. spinel's int model
# is int64-only, so the CRuby Bignum promotion path lowers to a
# user-catchable RangeError.
# spinel: wasm
begin
  "99999999999999999999".to_i
  puts "no exception"
rescue RangeError
  puts "to_i raised RangeError"
end

begin
  "ffffffffffffffff0".to_i(16)
  puts "no exception"
rescue RangeError
  puts "to_i(16) raised RangeError"
end

begin
  Integer("99999999999999999999")
  puts "no exception"
rescue RangeError
  puts "Integer raised RangeError"
end

# In-range values still work.
puts "42".to_i
puts "ff".to_i(16)
puts Integer("-1000")
