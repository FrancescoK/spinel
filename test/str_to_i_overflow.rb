# spinel: int64 -- assumes a 64-bit Integer (values or arithmetic past 2^31); not run on a 32-bit target
# spinel: not-cruby -- fixed-width overflow raises instead of promoting to Bignum.
# String#to_i overflow handling. Pre-fix: undefined behavior on
# int64 wrap (#743) — addressed by overflow-detected saturation.
# Per #842 the saturate path is gone; overflow now raises
# RangeError so a `rescue` can react instead of silently
# returning INT64_MAX/MIN.

# Below int64 limit: unchanged.
puts "12345".to_i
puts "-67890".to_i

# At/over int64 max: raises RangeError.
begin
  puts "99999999999999999999999999999".to_i
rescue RangeError
  puts "raised"
end

begin
  puts "-99999999999999999999999999999".to_i
rescue RangeError
  puts "raised"
end

# Exactly INT64_MAX: parses fine, no raise.
puts "9_223_372_036_854_775_807".to_i

# One past INT64_MAX: raises.
begin
  puts "9_223_372_036_854_775_808".to_i
rescue RangeError
  puts "raised"
end

# One below INT64_MIN must still raise after signed accumulation.
begin
  puts "-9223372036854775809".to_i
rescue RangeError
  puts "raised"
end
