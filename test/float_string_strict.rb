# Kernel#Float takes the whole String or refuses it: text after a valid prefix
# ("1.0foo"), an exponent with no digits ("1e"), a base prefix ("0b10", "0d10")
# and a comma are ArgumentError, and "1.e5" is a valid Float.
STRINGS = [
  "1e5", "1E5", "1e+5", "1e-5", "1e", "1e+", "1.e5", ".5", "-.5", "+.5", ".",
  "1_000.5", "1__0", "1e1_0", "1e_1", "1.5e", "1.5e5.5", "0x1p3", "0x1", "0x",
  "0d10", "0b10", "0o10", "0B1", "1.0foo", "1.0 foo", "  1.5  ", "1.5\n", "",
  "+", "-", "1e5e5", "e5", "1.5.5", "1f", "1.5f", "Infinity", "NaN", "1_e5",
  "1e5_", "1 e5", "1.5e-", "0.0e", "00", "010", "0e0", "1e400", "-0", "+0.0",
  "1.", "5.", "1.e", "0x1.8p1", "0x1.8", "1e0x1", "0b", "1_", "_1", "1.5_5",
  "1._5", "1.5__5", "0_1", "0e", "0d", "1,5", "1e5 x", "1. e5", "-1.e-2", "3.14",
  "12abc", "1.5.e5", "1.e5.", "1.0.", "1e5.", ".5.", "1.5e5.", "1_0.5.e5"
]

def try_float(s)
  Float(s)
rescue ArgumentError => e
  e.message
end

def try_soft(s) = Float(s, exception: false)

STRINGS.each do |s|
  puts "#{s.inspect} => #{try_float(s).inspect} #{try_soft(s).inspect}"
end

# the same String reached through a boxed slot
mixed = [1, "1.0foo", "1e", "0b10", "1.e5", 2.5]
mixed.each { |v| puts(try_float(v).inspect) if v.is_a?(String) }

# a `%f` argument that is a String converts the way Float() does
def try_format(s)
  format("%.1f", s)
rescue ArgumentError => e
  e.message
end
puts try_format("1.5x")
puts try_format("1.e1")
puts try_format("2.25")

# the other conversions that share the parser
def try_call
  yield
rescue ArgumentError, TypeError => e
  e.class
end
puts try_call { 1.coerce("1.5x") }.inspect
puts try_call { 1.coerce("1.5") }.inspect
puts try_call { 1.5.coerce("1e") }.inspect
puts try_call { (1..3).sum("1.5x") }.inspect
puts try_call { (1..3).sum("1.5") }.inspect
