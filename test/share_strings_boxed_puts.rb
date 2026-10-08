# Boxed mutable Strings keep their bytes and trailing newline in puts.
TEXT = "constant\n"

def copy_text(value)
  str = (value || TEXT).dup
  str.gsub!("constant", "copied")
  str
end

puts copy_text(nil)
puts copy_text("argument\n")

def print_value(value)
  puts value
end

plain = +"plain"
plain << "!"
line = +"line\n"
line << ""
binary = +"a\0b\n"
binary << ""
empty = +""
empty << ""
print_value(plain)
print_value(line)
print_value(binary)
print_value(empty)
print_value(nil)
print_value(7)
puts [line, [binary, nil], 8]
