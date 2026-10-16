# String#% with one Array element that can be nil as its argument: the
# element is held as a nullable Integer or Float while the argument list is
# built, and a nil element raises the conversion TypeError.
bytes = "0123456789abcdef".bytes
pattern = [[3, 2, 1, 0], [5, 4], [7, 6], [8, 9], 10..15]
puts pattern.map { |p| p.map { |n| "%02x" % bytes.to_a[n] }.join }.join("-")

floats = [1.5, 2.25, 3.125]
puts [[2, 0], 1..1].map { |p| p.map { |n| "%.2f" % floats.to_a[n] }.join(",") }.join(" ")

[[0], 20..20].each do |p|
  p.each do |n|
    puts "%02x" % bytes.to_a[n]
  rescue TypeError => e
    puts "TypeError: #{e.message}"
  end
end
