# A boxed MatchData answers begin(n), end(n), offset(n), byteoffset(n),
# match_length(n) and regexp, and a boxed Enumerator with_index (with or
# without an offset, with or without a block), next_values and
# peek_values, as typed ones do. A boxed Range keeps its own begin / end.
m = {m: "xAB!".match(/a(?<b>b)/i), n: 1}[:m]
p m.begin(0), m.end(:b), m.offset(1), m.byteoffset(0)
p m.match_length(1), m.regexp
e = [[3, 1, 2].each, 1][0]
p e.with_index.to_a
p e.with_index(1).map { |x, i| x * i }
e.with_index { |x, i| print x, i }
puts
e.with_index(1) { |x, i| print x * i }
puts
p e.next_values, e.peek_values, e.next
w = [%w[a b].each_with_index, 1][0]
p w.with_index.to_a
r = [(1..3), 1][0]
p r.begin, r.end
begin
  [5, 1][0].with_index
rescue NoMethodError => ex
  p ex.message
end
