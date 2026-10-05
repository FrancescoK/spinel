# spinel: int64
# Compare the parsed minimum directly: nullable storage and formatting of that
# bit pattern have separate restrictions, and are not part of decimal parsing.
minimum = -(2**62) * 2
[
  "-9223372036854775808",
  "-9_223_372_036_854_775_808",
  " \t-9223372036854775808suffix"
].each do |text|
  puts text.to_i == minimum
end
puts "-9223372036854775807".to_i == -9223372036854775807
puts "+9223372036854775807".to_i == 9223372036854775807
puts "0".to_i
puts "-0".to_i
puts "-42rest".to_i
puts "123_456rest".to_i
