# The two ends of a String Range, each made on the spot, are made in the
# order written, and the first is kept while the second is made.
def lo
  puts "lo"
  "b"
end

def hi
  puts "hi"
  "d"
end

p (lo..hi).to_a
r = (lo...hi)
p r.to_a
p (lo.dup..hi.dup).include?("c")

# a collection between the two ends takes neither
bad = 0
3000.times do |i|
  b = i.to_s
  e = (i + 3).to_s
  m = (i.to_s..(i + 3).to_s).max
  bad += 1 if m != (b > e ? nil : e)
end
p bad

none = 0
3000.times do |j|
  i = j + 100000
  none += 1 if (i.to_s...(i + 3).to_s).min.nil?
end
p none

i = 41
p ("k#{i}".."k#{i + 2}").to_a
x = "ab"
p (x.dup..x.succ).to_a
p (x.dup..).first
