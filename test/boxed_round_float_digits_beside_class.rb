# A boxed receiver's round, floor, ceil and truncate in a program where a
# class defines the method: a Float digit count is read as CRuby reads it,
# a RangeError for an infinity, a NaN and a Float past the word. The count
# was cast in C, which has no defined answer for those: v.floor(inf)
# answered 0 on x86-64.

def tell
  yield
rescue RangeError => e
  puts "RangeError: #{e.message}"
end

class Tile
  def round(d) = "tile round #{d}"
  def floor(d) = "tile floor #{d}"
  def ceil(d) = "tile ceil #{d}"
  def truncate(d) = "tile truncate #{d}"
end

vs = [1234, 12.5678, Tile.new, "str"]
v = vs[0]
u = vs[1]
w = vs[2]

[Float::INFINITY, -Float::INFINITY, Float::NAN, 10.0 ** 30].each do |d|
  tell { puts v.round(d) }
  tell { puts v.floor(d) }
  tell { puts v.ceil(d) }
  tell { puts v.truncate(d) }
  tell { puts u.round(d) }
  tell { puts u.floor(d) }
  tell { puts u.ceil(d) }
  tell { puts u.truncate(d) }
end

# a Float count inside the word keeps its answer
a = 2.9
b = -1.9
puts v.round(b), v.floor(b), v.ceil(b), v.truncate(b)
puts u.round(a), u.floor(a), u.ceil(a), u.truncate(a)
puts w.round(a), w.floor(a), w.ceil(b), w.truncate(b)

# a receiver with no such method says so before its count is read
t = vs[3]
[Float::INFINITY, a].each do |d|
  begin
    t.floor(d)
  rescue NoMethodError
    puts "NoMethodError"
  end
end
