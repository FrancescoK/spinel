x = nil
p x&.select
p x&.reject
p x&.find_all
p x&.each_pair
e = x&.filter_map
p e
p(e || :none)

def pick(i) = [nil, {a: 1, b: 2}][i]
[0, 1].each do |i|
  v = pick(i)
  s = v&.select
  p s.class
  p s&.size
end
