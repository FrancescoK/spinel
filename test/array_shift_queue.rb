# Array#shift on boxed, object, String and Float arrays
# A shift steps the array past its first element instead of moving the rest
# down, and a push that finds the array full takes the stepped-past slots
# back. These run queues through that: pushes and shifts interleaved across
# the move from inline elements to a payload, a queue drained and refilled,
# and the other Array operations on an array that was shifted.

# a breadth-first walk with a queue of [vertex, distance] pairs
n = 300
adj = Array.new(n) { |i| [(i + 1) % n, (i * 7 + 3) % n, (i * 13 + 5) % n] }
seen = Array.new(n, false)
queue = [[0, 0]]
seen[0] = true
order = []
far = 0
while !queue.empty?
  v, d = queue.shift
  order << v
  far = d if d > far
  adj[v].each do |w|
    next if seen[w]
    seen[w] = true
    queue.push([w, d + 1])
  end
end
p order.size, far, order.first(12), order.last(5)

# pushes and shifts interleaved: k pushes, then k - 1 shifts, so the queue
# grows by one each round while most of its room is stepped past
q = [[0, :a]]
total = 0
1.upto(40) do |k|
  k.times { |i| q.push([k * 100 + i, :b]) }
  (k - 1).times { total += q.shift[0] }
end
p q.size, total, q.first, q.last

# drained, then refilled past its old room
q2 = [["s", 0]]
q2.shift
p q2.empty?, q2.shift
20.times { |i| q2 << ["x", i] }
p q2.size, q2.first, q2.last
10.times { q2.shift }
q2.unshift(["u", 0])
q2.insert(3, ["i", 0])
p q2
p q2.reverse.first(3), q2.sort.first(3), q2.index(["x", 15]), q2.dup.size
q2.concat([["c", 1], ["c", 2]])
p q2.size, q2.last(3)
q2.freeze
begin
  q2.shift
rescue FrozenError => e
  p e.class
end

# a String array: drained, refilled, and replaced after shifts
names = ["a", "b"]
2.times { names.shift }
30.times { |i| names << "n#{i}" }
25.times { names.shift }
names.push("z")
p names, names.sort.first(2)
names.replace(["r1", "r2", "r3", "r4", "r5", "r6"])
names.shift
p names, names.join(",")

# a Float array, and one holding a nil, which shifts by moving its elements
fl = [0.5]
1.upto(30) do |k|
  fl << k * 1.5 << k * 0.25
  fl.shift
end
p fl.size, fl.first, fl.last, fl.sum
fl.unshift(-1.0)
p fl.first(3)
fn = [1.0, 2.0, 3.0, 4.0]
2.times { fn.shift }
fn[5] = 4.5
p fn, fn.shift, fn.shift, fn
20.times { |i| fn << i * 0.5 }
p fn.size, fn.first(6), fn.last
p fn.shift, fn.shift, fn.shift, fn.first(2)

# an object array
class Job
  attr_reader :id
  def initialize(id) = @id = id
end
jobs = [Job.new(0)]
done = []
next_id = 1
until jobs.empty?
  j = jobs.shift
  done << j.id
  if next_id < 200
    jobs.push(Job.new(next_id))
    jobs.push(Job.new(next_id + 1))
    next_id += 2
  end
end
p done.size, done.sum, done.last(3)

# shifted elements are collectable and the rest stay alive across a collection
held = Array.new(64) { |i| Job.new(i) }
50.times { held.shift }
GC.start
held << Job.new(99)
p held.map(&:id)

# short-lived arrays shifted and dropped: a collection reuses their room
acc = 0
2000.times do |i|
  t = [i, i + 1, i + 2, [i]]
  t.shift
  acc += t[0] + t[2][0]
  GC.start if i % 500 == 0
end
p acc

# an Array subclass holds its array in the object itself
class Line < Array
  def drain(k) = k.times.map { shift }
end
class Words < Array
  def drain(k) = k.times.map { shift }
end
line = Line.new
12.times { |i| line << i * 0.5 }
p line.drain(9), line.size
20.times { |i| line << i * 0.25 }
p line.first(2), line.last, line.size, line.class
words = Words.new
10.times { |i| words << "w#{i}" }
p words.drain(8)
15.times { |i| words << "v#{i}" }
p words.first(3), words.size, words.class
