# sample(n, random: g) and a boxed Array's shuffle / shuffle! / sample with
# random: draw every index from g, as a typed Array's do (#7561): the same
# seed repeats the result.
def t
  p yield
end
a = [3, 1, 2, 5, 4]
b = [a.dup, "x"][0]
t { a.sample(2, random: Random.new(3)) == a.sample(2, random: Random.new(3)) }
t { a.sample(2, random: Random.new(3)).size }
t { a.sample(9, random: Random.new(3)).sort }
t { a.sample(0, random: Random.new(3)) }
t { (a.sample(3, random: Random.new(4)) - a).empty? }
t { a.sample(3, random: Random.new(4)).uniq.size }
t { b.sample(random: Random.new(6)) == b.sample(random: Random.new(6)) }
t { a.include?(b.sample(random: Random.new(6))) }
t { b.sample(2, random: Random.new(1)) == b.sample(2, random: Random.new(1)) }
t { b.sample(2, random: Random.new(1)).size }
t { b.shuffle(random: Random.new(2)) == b.shuffle(random: Random.new(2)) }
t { b.shuffle(random: Random.new(2)).sort }
t { b.shuffle!(random: Random.new(5)).equal?(b) }
t { b.sort }
t { [[], 1][0].sample(random: Random.new(1)) }
t { [[], 1][0].sample(2, random: Random.new(1)) }
begin
  a.sample(-1, random: Random.new(1))
rescue ArgumentError => e
  p e.message
end
begin
  [1, [2]][0].sample(random: Random.new(1))
rescue NoMethodError => e
  p e.message
end
