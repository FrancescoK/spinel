# `print n.chr` writes the byte, and raises Integer#chr's RangeError
# outside 0..255, as Ruby does
[0, 65, 127, 128, 255].each { |n| print n.chr }
puts
[256, 300, -1].each do |n|
  begin
    print n.chr
  rescue RangeError => e
    puts "RangeError #{e.message}"
  end
end
def emit(n) = print(n.chr, "|")
emit(66)
begin
  emit(1000)
rescue RangeError => e
  puts e.message
end
puts
