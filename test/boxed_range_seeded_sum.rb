# sum with an initial value on a boxed Range, through a dispatch beside a
# class's own sum: with a block (sp_poly_sum_init_proc) a String Range
# walks its members, where it raised NoMethodError, and a Float Range
# raises the TypeError of its walk; without a block (sp_poly_sum_seed) a
# Float Range raises it too, where it answered the initial value.
class Bag
  def initialize(*xs) = @xs = xs
  def sum(init = 0) = @xs.sum(init) { |x| yield x }
end
def box(x) = [x, Bag.new(1, 2)].first
def try(name)
  r = yield
  puts "#{name}: #{r.inspect}"
rescue TypeError => e
  puts "#{name}: TypeError #{e.message}"
rescue NoMethodError => e
  puts "#{name}: NoMethodError #{e.message}"
end
try("float sum init") { box(1.0..2.0).sum(10) { |x| x } }
try("beginless sum init") { box(..2.0).sum(10) { |x| x } }
try("endless sum init") { box(1.0..).sum(10) { |x| x } }
try("str sum init") { box("a".."c").sum("") { |x| x } }
try("int sum init") { box(1..3).sum(10) { |x| x * 2 } }
try("bag sum init") { box(Bag.new(3, 4)).sum(10) { |x| x } }
try("float sum seed") { box(1.0..2.0).sum(10) }
try("str sum seed") { box("a".."c").sum("") }
try("int sum seed") { box(1..3).sum(10) }
try("beginless sum seed") { box(..2.0).sum(10) }
try("endless sum seed") { box(1.0..).sum(10) }
