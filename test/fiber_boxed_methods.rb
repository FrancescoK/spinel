# resume(arg), transfer and raise on a Fiber held in a boxed slot: an
# Array element, or a local that was nil first.

x = [Fiber.new { |a| b = Fiber.yield(a * 2); b + 1 }, 1][0]
p x.resume(21)
p x.resume(9)

root = Fiber.current
t = [Fiber.new { |v| root.transfer(v + 1) }, 1][0]
p t.transfer(4)

f2 = nil
f1 = Fiber.new do
  puts "f1"
  f2.transfer
  puts "back in f1"
  root.transfer(:end)
end
f2 = Fiber.new do
  puts "f2"
  f1.transfer
end
p f1.transfer

r = [Fiber.new { begin; Fiber.yield; rescue => e; e.message * 2; end }, 1][0]
r.resume
p r.raise("ab")

k = [Fiber.new { begin; Fiber.yield; rescue ArgumentError => e; e.message; end }, 1][0]
k.resume
p k.raise(ArgumentError, "arg")

u = [Fiber.new { Fiber.yield }, 1][0]
u.resume
begin
  u.raise(TypeError, "out")
rescue TypeError => e
  p e.message
end

n = [1, Fiber.new { }][0]
begin
  n.transfer
rescue NoMethodError => e
  p e.message
end
begin
  n.resume(1)
rescue NoMethodError => e
  p e.message
end
