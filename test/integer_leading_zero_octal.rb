# With base 0 (Integer(s), Integer(s, 0), String#to_i(0)) a leading 0 with
# no prefix letter reads the rest as octal, so 8, 9 and a "_" before them
# end the number: Integer() refuses such a String and to_i(0) stops there.
# The x, b, o and d prefixes, and a lone 0, keep their meaning.

def strict(s)
  Integer(s)
rescue ArgumentError => e
  e.class
end

def run
  ["08", "09", "0_8", "-08", "+09", " 08 ", "019", "0a"].each { |s| p [s, strict(s)] }
  ["07", "0_7", "-0_7", "017", " 017 ", "0", "00", "-0"].each { |s| p [s, strict(s)] }
  ["0x1f", "0b101", "0o17", "0d19", "0d08", "0o8"].each { |s| p [s, strict(s)] }
  p ["08", "0_8", "019", "017", "0d19"].map { |s| s.to_i(0) }
  p Integer("08", 0) rescue p $!.class
  p Integer("017", 0)
  p Integer("08", exception: false)
  p Integer("017", exception: false)
  p ["08", "017"].map { |s| s.to_i }   # base 10 is unchanged
  p Integer("08", 10)
end

run
