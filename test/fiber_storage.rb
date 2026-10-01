# Fiber storage: Fiber.new(storage:), Fiber#storage and #storage=.

p Fiber.current.storage
Fiber[:a] = 1

# storage: a Hash replaces the copy of the parent's, nil starts with none,
# true (and no keyword) copies the parent's
p Fiber.new(storage: {b: 2}) { [Fiber[:a], Fiber[:b]] }.resume
p Fiber.new(storage: nil) { [Fiber[:a], Fiber.current.storage] }.resume
p Fiber.new(storage: {}) { Fiber.current.storage }.resume
p Fiber.new(storage: true) { Fiber[:a] }.resume
p Fiber.new { Fiber.current.storage }.resume

# #storage is a copy, and a key set to nil is gone
s = Fiber.current.storage
s[:z] = 1
p Fiber[:z]
Fiber[:gone] = 1
Fiber[:gone] = nil
p Fiber.current.storage

# changes in a child stay in the child
f = Fiber.new { Fiber[:a] = 9; Fiber.current.storage }
p f.resume
p Fiber[:a]

# #storage= replaces the running fiber's storage; nil clears it
$stderr.reopen(File::NULL)   # CRuby warns that storage= is experimental
g = Fiber.new { Fiber.current.storage = {c: 3}; [Fiber[:a], Fiber[:c]] }
p g.resume

# only the fiber itself may read or replace it, and only with Symbol keys
h = Fiber.new { Fiber.yield; :done }
h.resume
begin
  h.storage
rescue ArgumentError => e
  p e.message
end
begin
  h.storage = {}
rescue ArgumentError => e
  p e.message
end
begin
  Fiber.new(storage: {"s" => 1}) { }
rescue TypeError => e
  p e.message
end
begin
  Fiber.new(storage: 5) { }
rescue TypeError => e
  p e.message
end

# a thread starts with a copy of its creator's storage
p Thread.new { Fiber[:a] }.value

many = Fiber.new(storage: (1..50).to_h { |i| [:"k#{i}", "v#{i}" * 3] }) do
  GC.start
  [Fiber.current.storage.size, Fiber[:k50]]
end
p many.resume


# the storage: value is evaluated, and kept alive, before the fiber exists
def mk(i) = {k: "x" * i, j: [i, "y" * i]}
made = []
200.times { |i| made << Fiber.new(storage: mk(i)) { Fiber[:j][0] } }
p made.map(&:resume).sum
Fiber[:y] = 7
p Fiber.new(storage: (Fiber[:y] = 8; true)) { Fiber[:y] }.resume

# a nil value given in storage: stays; Fiber[]= nil removes the key
p Fiber.new(storage: {a: nil, b: 1}) { Fiber.current.storage }.resume
p Fiber.new(storage: {a: nil, b: 1}) { Fiber[:b] = nil; Fiber.current.storage }.resume

Fiber.current.storage = nil
p Fiber[:a]
p Fiber.current.storage
