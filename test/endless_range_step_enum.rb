# step(n) and % n without a block on an endless Range answer an Enumerator
# walked only as far as it is read, as CRuby's arithmetic sequence is,
# where materializing it raised RangeError. Bounded ranges are unchanged.
def t
  p yield
rescue => e
  puts "#{e.class}: #{e.message}"
end
t { (1..).step(3).first(3) }
t { ((1..) % 3).first(3) }
t { (1...).step(3).first(2) }
t { (1..).step(-1).first(3) }
t { (1..).step(2.5).first(3) }
t { (1.0..).step(1).first(3) }
t { (1.5..).step(0.5).first(3) }
t { (1..).step(3).take(2) }
t { (1..).step(3).lazy.map { |x| x * 2 }.first(2) }
t { (1..).step(3).each { |x| break x if x > 5 } }
t { (1..).step(3).find { |x| x > 5 } }
t { (1..).step(3).take_while { |x| x < 10 } }
t { (1..).step(3).each_slice(2).first }
t { (1..).step(3).with_index.first(2) }
t { (1..).step(3).size }
t { e = (1..).step(3); [e.next, e.next, e.next] }
t { (1..).step(0) }
t { (1.0..).step(0.0) }
r = (5..)
t { r.step(5).first(3) }
t { (1..).step(3).first }
t { (1..10).step(3).to_a }
t { ((1..10) % 4).to_a }
t { (1.0..2.0).step(0.5).to_a }
t { (0.1..).step(0.1).first(4) }
x = [(1..), 1][0]
t { (x % 3).first(3) }
t { ([(1.5..), 1][0] % 0.5).first(3) }
t { ([(1..10), 1][0] % 4).to_a }
