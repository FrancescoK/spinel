# A Float Range as the index of an Array or a String converts each end
# with to_int, in a variable as well as written in place.

b = [1, 2, 3, 4]
p b.slice(0.5...2.5)
p b.slice(0.5..)
p b.values_at(1.5..2)
p b.values_at(0.5..1.5, 3)

r = 1.5..2
p b[r]
p b.slice(r)
p b.values_at(r)
p [1.5, 2.5, 3.5][r]
p %w[a b c][r]
p ["a", 1, :c, 2.0][r]
p ["a", 1, :c, 2.0].slice(0.5..1.5)
p b[(1.5..)]
p b[(..1.5)]
p b.slice((...1.5))
p b[-2.5..-1.5]

c = [1, 2, 3, 4]
p c.slice!(0.5..1.5)
p c
c = [1, 2, 3, 4]
p c.slice!(r)
p c
c = [1, 2, 3, 4]
c[0.5..1.5] = [9]
p c
c = [1, 2, 3, 4]
c[r] = 7
p c
c = [1, 2, 3, 4]
x = (c[r] = [8, 9])
p x, c

s = "abcd"
p s[r]
p s.slice(r)
p s.byteslice(r)
p s.byteslice(0.5..1.5)
t = +"abcd"
p t.slice!(0.5..1.5)
p t
t = +"abcd"
p t.slice!(r)
p t
t = +"abcd"
t[0.5..1.5] = "X"
p t
t = +"abcd"
t[r] = "Y"
p t

def rng
  puts "rng"
  0.5..1.5
end

def arr
  puts "arr"
  [1, 2, 3, 4]
end

p arr[rng]
p arr.values_at(rng, 3)

begin
  p b[1.0..Float::INFINITY]
rescue RangeError => e
  p e.message
end
