# Kernel#Integer with a negative radix: a leading 0 selects the prefix,
# otherwise the radix's absolute value is used, and -1 is base 10.
def try(label)
  r = begin
    yield
  rescue => e
    [e.class, e.message]
  end
  puts "#{label} => #{r.inspect}"
end

try("0x1f, -16") { Integer("0x1f", -16) }
try("1f, -16") { Integer("1f", -16) }
try("0b11, -10") { Integer("0b11", -10) }
try("017, -10") { Integer("017", -10) }
try("0o17, -2") { Integer("0o17", -2) }
try("0d19, -16") { Integer("0d19", -16) }
try("10, -2") { Integer("10", -2) }
try("z, -36") { Integer("z", -36) }
try("0, -16") { Integer("0", -16) }
try("signed, -16") { Integer("  -1f  ", -16) }
try("signed prefix, -16") { Integer(" -0x1f", -16) }
try("11, -1") { Integer("11", -1) }
try("011, -1") { Integer("011", -1) }
try("08, -10") { Integer("08", -10) }
try("0x, -16") { Integer("0x", -16) }
try("0b2, -16") { Integer("0b2", -16) }
try("1, -37") { Integer("1", -37) }
try("1f, -16, exception: false") { Integer("1f", -16, exception: false) }
try("zz, -16, exception: false") { Integer("zz", -16, exception: false) }
base = [-16, 10][0]
try("variable radix") { Integer("ff", base) }
vals = ["0x1f", 1]
try("boxed String") { Integer(vals[0], -16) }
try("String#to_i(-16)") { "1f".to_i(-16) }
class RadixDigits
  def to_str = "0b101"
end
try("#to_str, -10") { Integer(RadixDigits.new, -10) }
try("1f, -2**31") { Integer("1f", -2147483648) }
