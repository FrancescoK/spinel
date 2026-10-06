# A blockless step with a Float step on an endless Range read out of a
# mixed Array walks as an Enumerator, as the Integer step does; it had
# been typed a Float Array and raised "range too large to materialize".
xs = [(1.5..), (1..), (0..2), (0.5..1.5), 1, 2.0]
p xs[0].step(0.5).first(3)
p xs[1].step(0.5).first(3)
p xs[0].step(2).first(2)
p xs[1].step(2).first(3)
p xs[2].step(0.5).to_a
p xs[3].step(0.25).to_a
p xs[2].step(1).to_a
p xs[4].step(3, 0.5).to_a
p xs[5].step(3.0).to_a
xs[0].step(0.5) { |x| break if x > 2.5; p x }
e = xs[0].step(0.5)
p e.next
p e.next
