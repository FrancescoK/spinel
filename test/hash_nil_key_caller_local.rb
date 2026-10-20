# A method that fills an empty Hash local with `[]=`, keyed by an Integer that
# can be nil, and answers it, called into a local of the caller
# (`h = first_seen(a)`). The late widening of the local and the method's
# return refused a call whose value lands in a variable, so the Hash stayed
# typed and the nil key was refused at run time (a TypeError) where CRuby
# stores it. A local that holds only such calls and hands nothing on whole is
# retyped with the method's return.
def first_seen(a)
  seen = {}
  a.each_with_index { |x, i| seen[x] = i unless seen.key?(x) }
  seen
end

def cnt(a)
  seen = {}
  a.each { |x| seen[x] = (seen[x] || 0) + 1 }
  seen
end

b = [5, 6][ARGV.size + 7]
h = first_seen([3, b, 3, b])
p h
p h.size
z = [1, 2][ARGV.size + 9]
g = cnt([z])
g[z] += 5
g[7] = 1
p g
g.each { |k, v| p [k, v] }
