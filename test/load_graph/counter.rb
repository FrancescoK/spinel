x = 10
$order << :counter_start
require_relative "limits"
class Counter
  @total = 0
  def self.add(n)
    @total += n
  end

  def self.total
    @total
  end
end
i = 0
while i < LIMIT
  Counter.add(i * x)
  i += 1
end
puts "counter: #{x}"
$order << :counter_end
