def pick(n) = n > 1 ? [1, 2, 3, 4] : "abcd"
def start(n) = n > 2 ? 1 : nil
a = pick(ARGV.size + 2)
p a.fill(7, nil)
p a.fill(8, nil, 2)
p a.fill(9, start(ARGV.size))
p a.fill(6, start(ARGV.size), 1)
b = [1, 2, 3, 4]
p b.fill(7, nil)
p b.fill(8, nil, 2)
p b.fill(9, start(ARGV.size))
p b.fill(6, start(ARGV.size), 1)
c = [1.0, 2.0, 3.0]
p c.fill(7.5, nil)
p c.fill(1.5, start(ARGV.size), 2)
d = ["a", "b", "c"]
p d.fill("z", nil)
p d.fill("y", start(ARGV.size))
p b.fill(nil) { |i| i * 2 }
p b.fill(start(ARGV.size)) { |i| i * 3 }
a = pick(ARGV.size + 2)
p a.fill(5, 1, start(ARGV.size))
p a.fill(nil) { |i| i * 2 }
p a.fill(start(ARGV.size)) { |i| i * 3 }
p a.fill(1, start(ARGV.size)) { |i| i * 4 }
b = [1, 2, 3, 4]
p b.fill(5, 1, start(ARGV.size))
p b.fill(1, start(ARGV.size)) { |i| i * 4 }
p b.fill(-2, nil) { |i| i * 5 }
x = start(ARGV.size)
p b.fill(0, x)
p b.fill(x) { |i| -i }
begin
  b.fill(0, "x")
rescue TypeError => e
  puts e.message
end
begin
  b.fill("x") { |i| i }
rescue TypeError => e
  puts e.message
end
