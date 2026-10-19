# Range#cover? on a boxed receiver while a class of the program's own
# defines cover? too: a Range still answers it, the class takes its own
# method, and a receiver that has neither raises NoMethodError. The Range
# raised NoMethodError, and a receiver with no cover? answered false.

class Window
  def initialize(r) = @range = r
  def cover?(x) = @range.cover?(x.is_a?(Window) ? x.range : x)
  def range = @range
end

def pick(a, i) = a[i]
rs = [(1..5), Window.new(10..20), (2.0..3.0), ("b".."d"), [1, 2]]
p pick(rs, 0).cover?(3), pick(rs, 0).cover?(9)
p pick(rs, 1).cover?(15), pick(rs, 1).cover?(3)
p pick(rs, 2).cover?(2.5), pick(rs, 3).cover?("c")
p pick(rs, 0).cover?(2..4), pick(rs, 0).cover?(4..7)
begin
  pick(rs, 4).cover?(1)
rescue NoMethodError => e
  puts e.message
end

# a Range built from ends that are boxed
def setting(k) = { "Min" => 1, "Max" => nil }[k]
def lo = setting("Min") || 1
def hi = setting("Max") || lo + 1
def fits?(n) = (lo..hi).cover?(n)
p fits?(1), fits?(2), fits?(3)
p Window.new(1..3).cover?(2)

# with no class of the program's own defining it
def kinds = [(1..2), :sym]
begin
  p kinds[0].cover?(2)
  kinds[1].cover?(1)
rescue NoMethodError => e
  puts e.message
end
