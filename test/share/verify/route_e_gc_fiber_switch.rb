s = +"s"
t = s
f = Fiber.new do
  loop do
    t << "f"
    junk = Array.new(20) { |i| "z#{i}" }
    Fiber.yield t.size
  end
end
r = 0
30.times { r = f.resume; s << "m" }
p r, s.size, t.equal?(s)
