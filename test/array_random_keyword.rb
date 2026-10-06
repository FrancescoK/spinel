# shuffle, shuffle! and sample given `random:` draw from that generator, so a
# seed repeats its order (Spinel's Random is not CRuby's sequence, so this
# checks the properties, not the orders).
def t
  p yield
rescue => e
  puts "#{e.class}: #{e.message}"
end
a = (1..20).to_a
s = %w[a b c d e f g h]
f = [1.5, 2.5, 3.5, 4.5, 5.5]
t { a.shuffle(random: Random.new(5)).sort == a }
t { a.shuffle(random: Random.new(5)) == a.shuffle(random: Random.new(5)) }
t { s.shuffle(random: Random.new(9)) == s.shuffle(random: Random.new(9)) }
t { s.shuffle(random: Random.new(9)).sort == s }
t { f.shuffle(random: Random.new(3)).sort == f }
t { b = a.dup; c = a.dup; b.shuffle!(random: Random.new(4)); c.shuffle!(random: Random.new(4)); b == c && b.sort == a }
t { b = a.dup; b.shuffle!(random: Random.new(4)).equal?(b) }
t { a.sample(random: Random.new(6)) == a.sample(random: Random.new(6)) }
t { a.include?(a.sample(random: Random.new(6))) }
t { s.include?(s.sample(random: Random.new(2))) }
t { [].sample(random: Random.new(1)) }
t { [].shuffle(random: Random.new(1)) }
t { [7].shuffle(random: Random.new(1)) }
t { [1, 2].freeze.shuffle!(random: Random.new(1)) }
t { g = Random.new(8); x = a.shuffle(random: g); y = a.shuffle(random: g); x.sort == y.sort }
t { a }
