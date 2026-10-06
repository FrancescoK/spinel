# step(n) without a block on an endless Range read out of a mixed Array walks
# as an Enumerator, as on a typed one (#7537); any other receiver steps as
# before.
def t
  p yield
rescue => e
  puts "#{e.class}: #{e.message}"
end
x = [(1..), 1][0]
t { x.step(3).first(3) }
t { x.step(3).take(2) }
t { x.step(3).lazy.map { |v| v * 2 }.first(2) }
t { x.step(3).find { |v| v > 5 } }
t { [(1..10), 1][0].step(3).to_a }
t { [(1.0..2.0), 1][0].step(0.5).to_a }
t { [5, :a][0].step(10).to_a }
t { [2.5, :a][0].step(4).to_a }
t { x.step(0) }
t { [:s, 1][0].step(3) }
