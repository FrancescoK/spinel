class Bus
  def initialize(flag)
    @pages = flag ? Array.new(4, 0) : [nil, "x", 1, 2]
  end
  def fb = @pages.fill(1) { |i| i * 10 }
  def fa = @pages.fill { |i| i + 1 }
  def fr = @pages.fill(1, 2) { |i| -i }
  def fv = @pages.fill(5, 2)
  def pages = @pages
end
[true, false].each do |f|
  b = Bus.new(f)
  r = b.fb
  p r
  p b.fa
  p b.fr
  p b.fv
end
