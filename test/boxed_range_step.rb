# step(n) without a block on a Range read out of a mixed Array walks it like
# a plain Range; a boxed Integer and Float keep their own step.
x = [(1..10), 5][0]
p x.step(3).to_a
p [(1...10), 5][0].step(3).to_a
p [(1.0..2.0), 5][0].step(0.5).to_a
p x.step(3).map { |v| v * 2 }
p [5, :a][0].step(10, 3).to_a
p [2.5, :a][0].step(9, 3).to_a
def t
  p yield
rescue => e
  puts "#{e.class}: #{e.message}"
end
t { x.step(0).to_a }
t { x.step(-1).to_a }
t { [:a, 1][0].step(3) }
