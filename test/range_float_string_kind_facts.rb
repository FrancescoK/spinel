# A Float or a String Range is Enumerable, and covers a Range by comparing
# endpoints, as an Integer Range already did: is_a?(Enumerable) answered
# false for both, and cover? with a Float or String Range argument (the
# range itself included) answered false. A Float Range also covers an
# Integer Range by its endpoints.

fr = (1.0..2.5)
fx = (1.0...2.5)
fe = (1.0..)
fb = (..2.5)
sr = ("a".."e")
sx = ("a"..."e")
se = ("a"..)
p [fr.is_a?(Enumerable), sr.is_a?(Enumerable), se.kind_of?(Enumerable), fe.is_a?(Enumerable), Enumerable === fr, Enumerable === sr]
p [fr.is_a?(Comparable), sr.is_a?(Comparable), fr.instance_of?(Range)]
p [fr.cover?(fr), fr.cover?(1.5..2.0), fr.cover?(1.5..3.0), fr.cover?(0.5..2.0), fr.cover?(fx), fx.cover?(fr), fx.cover?(fx)]
p [fe.cover?(fe), fe.cover?(fr), fr.cover?(fe), fb.cover?(fb), fb.cover?(fr), fr.cover?(fb), fe.cover?(fb)]
p [fr.cover?(2.0..1.0), fr.cover?(1.0...1.0), fr.cover?(1..2), fr.cover?(1..3), fx.cover?(1...3)]
p [sr.cover?(sr), sr.cover?("b".."c"), sr.cover?("b".."z"), sr.cover?(sx), sx.cover?(sr), sx.cover?(sx)]
p [se.cover?(se), se.cover?(sr), sr.cover?(se), sr.cover?("c".."b"), sr.cover?("a"..."a"), sx.cover?("b"..."e")]
x = [fr, 1]
p x[0].is_a?(Enumerable)

# boxed receivers and arguments
boxed_ranges = [(1.0..2.5), ("a".."e"), (1..5)]
inner_ranges = [(1.5..2.0), ("b".."c"), (2..3)]
boxed_ranges.each_with_index { |r, i| p [r.cover?(inner_ranges[i]), r.cover?(r), r.is_a?(Enumerable)] }
p [fr.cover?(inner_ranges[0]), sr.cover?(inner_ranges[1]), fr.cover?(inner_ranges[2]), sr.cover?(inner_ranges[0])]
p [boxed_ranges[0].cover?(fr), boxed_ranges[1].cover?(sr), boxed_ranges[1].cover?("c")]
