def pick(n) = n > 1 ? [1, 2, 3, 4] : "abcd"
b = [1, 2, 3, 4]
p b.fill(0, 1.5..2)
p [1, 2, 3, 4].fill(0, 1.5, 2.0)
p [1, 2, 3, 4].fill(0, 2.9)
p [1.0, 2.0, 3.0].fill(0.5, 0.5..1.5)
p ["a", "b", "c"].fill("z", 1.0...3.0)
a = pick(ARGV.size + 2)
p a.fill(0, 1.5..2)
p a.fill(5, 1.5, 2.0)
p a.fill(6, 2.9)
p [1, 2, 3, 4].fill(1.5..2) { |i| i * 10 }
p [1, 2, 3, 4].fill(1.5, 2.0) { |i| i * 10 }
def rng(n) = n > 1 ? (1.5..2) : 1
r = 0.5...2.9
p [1, 2, 3, 4].fill(0, r)
p [1, 2, 3, 4].fill(0, 2.5..)
p [1, 2, 3, 4].fill(0, ..1.5)
p [1, 2, 3, 4].fill(0, -2.5..-1.5)
p [1, 2].fill(0, 1.5..4.2)
p [1, 2, 3, 4].fill(0, rng(ARGV.size + 2))
a = pick(ARGV.size + 2)
p a.fill(8, rng(ARGV.size + 2))
p a.fill(3, r)
p [1, 2, 3, 4].fill(r) { |i| i * 10 }
p [1, 2, 3, 4].fill(2.5..) { |i| i * 10 }
p [1, 2].fill(0..3) { |i| i * 10 }
begin
  [1, 2].fill(0, -5.5..1)
rescue RangeError => e
  puts "RangeError: #{e.message}"
end
begin
  [1, 2].fill(-5..1) { |i| i }
rescue RangeError => e
  puts "RangeError: #{e.message}"
end
begin
  [1, 2].fill(-5.5..1) { |i| i }
rescue RangeError => e
  puts "RangeError: #{e.message}"
end
p [1, 2].fill(0..3) { |i| i * 10 }
begin
  [1, 2].fill(-5..1) { |i| i }
rescue RangeError => e
  puts "RangeError: #{e.message}"
end
p [1, 2, 3].fill(-2..) { |i| i }
