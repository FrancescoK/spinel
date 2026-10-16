# slice_when, chunk_while and chunk over an Integer or Float Array holding a
# nil element bind that nil to their block parameters, plainly typed ones
# included.
a = [1, 2]
a[3] = 5
p a.slice_when { |x, y| y.nil? || x.nil? }.to_a
p a.chunk_while { |x, y| !x.nil? && !y.nil? }.to_a
p a.chunk { |x| x.nil? }.to_a
p a.chunk { |x| x.nil? ? :n : x.odd? }.to_a

f = [1.5, 2.5]
f[3] = 0.5
p f.slice_when { |x, y| y.nil? }.to_a
p f.chunk_while { |x, y| !x.nil? && !y.nil? }.to_a
p f.chunk { |x| x.nil? }.to_a

b = [1, 2, 4, 5, 7]
p b.slice_when { |x, y| y != x + 1 }.to_a
p b.chunk_while { |x, y| y == x + 1 }.to_a
p [1.0, 1.5, 3.0].slice_when { |x, y| y - x > 1.0 }.to_a
