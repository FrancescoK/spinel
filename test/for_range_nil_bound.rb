# `for i in lo..hi` whose end is nil iterates an endless range (until a
# break), and one whose beginning is nil cannot be iterated (TypeError).
# A boxed or nullable nil end read as 0 or INT64_MIN, so the loop ran zero
# times.

src = [1, nil, "s", 3]
lo = src[0]
r = []
for i in lo..src[1]
  r << i
  break if i > 2
end
p r

h = {a: 2}
e = h[:b]
r = []
for i in 1...e
  r << i
  break if i >= 4
end
p r

r = []
for i in 5..nil
  r << i
  break if i > 6
end
p r

r = []
for i in lo..src[3]
  r << i
end
p r

begin
  for i in src[1]..3
    p i
  end
rescue TypeError => ex
  puts "#{ex.class}: #{ex.message}"
end

# the same nil bounds in a Range built at run time: endless and beginless
rr = lo..src[1]
r = []
for i in rr
  r << i
  break if i > 2
end
p r
r = []
(lo..src[1]).each { |i| r << i; break if i > 2 }
p r
q = src[1]..3
p q.include?(-5)
p q.include?(4)
p (lo..src[1]).include?(10**6)
