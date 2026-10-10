# spinel: int64 -- the indexes below pass 2^31
# A read of a Float or Integer array through a method parameter's index, so
# the program's loops do not cache the array's header: in range, past the end,
# negative in range, negative past the start, and indexes far outside the
# length, for full, shifted and empty arrays.

def fread(a, i)
  x = a[i]
  x.nil? ? "nil" : x.to_s
end

def iread(a, i)
  x = a[i]
  x.nil? ? "nil" : x.to_s
end

indexes = [0, 1, 2, 3, 4, -1, -2, -3, -4, -5, 100, -100,
           2**31, -(2**31), 2**62, -(2**62), 9223372036854775807, -9223372036854775807]

fa = [1.5, 2.5, 3.5]
ia = [10, 20, 30]
indexes.each do |i|
  puts "#{i}: #{fread(fa, i)} #{iread(ia, i)}"
end

# an Integer array whose front was shifted off reads from its new start
sa = [1, 2, 3, 4, 5]
sa.shift
sa.shift
indexes.first(10).each do |i|
  puts "shifted #{i}: #{iread(sa, i)}"
end

# an array that grew and shrank
fb = [1.0, 2.0, 3.0, 4.0]
fb.pop
ib = [1, 2, 3, 4]
ib.pop
[2, 3, -3, -4].each do |i|
  puts "popped #{i}: #{fread(fb, i)} #{iread(ib, i)}"
end

# empty arrays
fe = [1.5]
fe.clear
ie = [1]
ie.clear
[0, 1, -1].each do |i|
  puts "empty #{i}: #{fread(fe, i)} #{iread(ie, i)}"
end

# first and last read through the same accessor
puts fa.first, fa.last, ia.first, ia.last
puts fe.first.inspect, fe.last.inspect, ie.first.inspect, ie.last.inspect
