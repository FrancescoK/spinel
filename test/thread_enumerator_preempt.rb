# Green threads iterating Enumerators long enough to be preempted, some
# slices landing inside the Enumerator's fiber
def body = Enumerator.new { |y| 3.times { |i| y << i } }
threads = 2.times.map do
  Thread.new do
    n = 0
    20_000.times { body.each { |s| n += s } }
    n
  end
end
p threads.map(&:value)
lazy = Thread.new { Enumerator.new { |y| 5.times { |i| y << i * i } }.to_a }
p lazy.value
