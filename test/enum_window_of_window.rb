# A blockless each_slice / each_cons of the Enumerator another one answers
# (`parts.each_slice(2).each_cons(2)`): an Enumerator of the windows of the
# windows, as in CRuby. It was refused at compile time.

def clauses(xs) = xs.sort_by { |x| x }.each_slice(2).each_cons(2)

clauses([4, 1, 3, 2, 6, 5]).each do |(a, b), (c, d)|
  p [a, b, c, d]
end
p [1, 2, 3].each_slice(1).each_cons(2).to_a
p [1, 2, 3, 4].each_slice(2).each_slice(1).to_a
p [1, 2, 3, 4].each_cons(2).each_slice(2).to_a
p [1, 2, 3, 4].each_cons(3).each_cons(2).map { |x, y| x.sum + y.sum }
[1, 2, 3, 4, 5].each_slice(2).each_cons(2) { |x, y| p [x, y] }
p [].each_slice(2).each_cons(2).to_a
