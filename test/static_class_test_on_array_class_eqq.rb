# A class test on a typed Array is decided where the Array settles, unless
# the program defines `===` on Class (or Module), which every `K === v` with
# K a class then calls: the test stays a run-time one and answers as the
# program's method does.
class Class
  def ===(other) = true
end

def kinds(a)
  r = []
  r << (Hash === a ? "hash" : "not hash")
  r << (Array === a ? "array" : "not array")
  r << (Integer === a ? "integer" : "not integer")
  r << (Enumerable === a ? "enumerable" : "not enumerable")
  r
end

p kinds([1, 2])
p kinds(%w[a b])
a = [1, 2]
if Hash === a
  puts "hash"
else
  puts "not hash"
end
puts "unless ran" unless Integer === a
