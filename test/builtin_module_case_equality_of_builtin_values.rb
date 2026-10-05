values = [Time.at(0), :sym, Rational(1, 2), 1.5, 2**70, "text", [1].each, 1..2, 1.0..2.0, {a: 1}, [1], Dir.new("."), nil]
values.each do |value|
  puts "#{value.class}: #{Comparable === value} #{Enumerable === value}"
end
missing = [1, 2].index(9)
puts "#{Comparable === missing} #{Enumerable === missing}"
time = Time.at(0)
enumerator = [1].each
dir = Dir.new(".")
puts "#{Comparable === time} #{Enumerable === enumerator} #{Enumerable === dir}"
