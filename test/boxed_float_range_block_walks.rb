# A boxed Float Range walked by a block method that a class of the program
# also defines: the call is a dispatch, and the Range fell to the user-class
# switch's NoMethodError. CRuby raises TypeError (can't iterate from Float,
# or from NilClass when beginless), as Spinel does without such a class.
class Bag
  def initialize(*xs) = @xs = xs
  def each
    @xs.each { |x| yield x }
    self
  end
  def map = @xs.map { |x| yield x }
  def select = @xs.select { |x| yield x }
  def count = @xs.count { |x| yield x }
  def sum = @xs.sum { |x| yield x }
  def each_with_index = @xs.each_with_index { |x, i| yield x, i }
  def find = @xs.find { |x| yield x }
  def any? = @xs.any? { |x| yield x }
  def sort_by = @xs.sort_by { |x| yield x }
  def reverse_each = @xs.reverse_each { |x| yield x }
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

f = box(1.0..2.0)
try("each") { f.each { |x| x } }
try("map") { f.map { |x| x } }
try("select") { f.select { |x| x } }
try("count") { f.count { |x| x } }
try("sum") { f.sum { |x| x } }
try("each_with_index") { f.each_with_index { |x, i| x } }
try("find") { f.find { |x| x } }
try("any?") { f.any? { |x| x } }
try("sort_by") { f.sort_by { |x| x } }
try("reverse_each") { f.reverse_each { |x| x } }
try("beginless each") { box(..2.0).each { |x| x } }
try("endless each") { box(1.0..).each { |x| break x } }

i = box(1..4)
try("int each") { i.each { |x| x } }
try("int map") { i.map { |x| x * 2 } }
try("bag map") { box(Bag.new(3, 4)).map { |x| x + 1 } }
