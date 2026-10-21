# SPINEL_WORKERS=1 is one OS worker in all: main runs every thread itself
# (#9840), and gives the runnable ones their slices while its own code runs,
# as CRuby's one GVL does. Main spinning on what a thread sets, or reading
# what a thread writes, sees it. (Read when the first thread starts; CRuby
# ignores it.)
ENV["SPINEL_WORKERS"] = "1"

$flag = false
t = Thread.new { $flag = true }
i = 0
i += 1 until $flag
t.join
puts "flag seen"

q = Queue.new
producer = Thread.new { 3.times { |k| q << k } ; q << :done }
got = []
while (v = q.pop) != :done
  got << v
end
producer.join
p got

r, w = IO.pipe
writer = Thread.new do
  3.times { sleep 0.02; w.write("x") }
  w.close
end
p r.read
writer.join

counts = Array.new(3, 0)
ths = 3.times.map { |k| Thread.new { 1000.times { counts[k] += 1 } } }
ths.each(&:join)
p counts
