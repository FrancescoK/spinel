# An endless Enumerator reached through a boxed value is walked one item at
# a time, so a block that stops early (find, any?, a break) stops it.
class Box
  def initialize(v) = @v = v
  def find
    yield(@v) ? @v : nil
  end
  def any?
    yield(@v)
  end
end

inf = Enumerator.new { |y| i = 0; loop { y << (i += 1) } }
[inf, [1, 2, 3, 4].cycle, [1, 2, 3, 4]].each do |en|
  p en.find { |x| x > 2 }
  p en.detect { |x| x > 2 }
  p en.any? { |x| x > 2 }
  p en.find_index { |x| x > 2 }
  p en.take_while { |x| x < 3 }
  p en.first
  p en.each { |x| break x * 10 if x > 2 }
  p en.each_with_index { |x, i| break [x, i] if i > 1 }
end

[inf, [5, 6, 7].cycle, Box.new(7)].each do |en|
  p en.find { |x| x > 5 }
  p en.any? { |x| x == 6 }
end

def pick(en) = en.find { |a| a.to_s.size > 1 }
p pick(inf)
p pick([1, 22].cycle)

# a finite generator still walks to its end, and is walked afresh each time
fin = Enumerator.new { |y| y << 1; y << 2; y << 3 }
[fin, fin].each do |en|
  p en.find { |x| x > 5 }
  p en.all? { |x| x > 0 }
  p en.count { |x| x.odd? }
end
p fin.next
p [fin].map { |en| en.find { |x| x > 1 } }
p fin.next
