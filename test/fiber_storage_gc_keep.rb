# A fiber made with a copy of its maker's storage keeps it through a
# collection, and so does the main thread's storage while other threads run.
Fiber[:k] = "t"
fs = 6.times.map do |j|
  Fiber.new do
    Fiber[:j] = "f#{j}"
    y = []
    200.times { |n| y << "z#{n}" }
    Fiber.yield [Fiber[:j], Fiber[:k]]
    Fiber[:j]
  end
end
a = fs.map(&:resume)
100.times { |n| "w#{n}" * 3 }
b = fs.map(&:resume)
p a, b

Fiber[:main] = "m"
ths = 4.times.map do |i|
  Thread.new(i) do |k|
    Fiber[:k] = "t#{k}"
    gs = 3.times.map do |j|
      Fiber.new do
        Fiber[:j] = "f#{k}-#{j}"
        y = []
        200.times { |n| y << "z#{n}" }
        Fiber.yield [Fiber[:j], Fiber[:k]]
        Fiber[:j]
      end
    end
    c = gs.map(&:resume)
    100.times { |n| "w#{n}" * 3 }
    d = gs.map(&:resume)
    [Fiber[:k], Fiber[:main], c, d]
  end
end
ths.each { |t| p t.value }
p Fiber[:main]
