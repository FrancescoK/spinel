# String#between? and String#clamp with a bound whose type is only known at
# run time (a boxed value: a String or an Integer from the same variable).
# A String bound compares by bytes; any other raises CRuby's comparison
# error. The boxed bound was handed to the byte compare as a C string, and
# the program did not compile.
def t
  r = yield
  r.inspect
rescue => e
  "#{e.class}: #{e.message}"
end

int_or_str = ARGV.size > 0 ? "z" : 99
str_or_int = ARGV.size > 0 ? 99 : "9"
nil_or_str = ARGV.size > 0 ? "a" : nil

puts t { "12".between?("1", int_or_str) }
puts t { "12".between?(int_or_str, "z") }
puts t { "12".between?("1", str_or_int) }
puts t { "12".between?(str_or_int, "z") }
puts t { "12".clamp("1", int_or_str) }
puts t { "12".clamp("1", str_or_int) }
puts t { "12".clamp(str_or_int, "z") }
puts t { "12".clamp(nil_or_str, "1") }
