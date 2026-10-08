# Flag-only: `inject` with a String seed whose accumulator the block hands
# back answers the seed itself, so a change through the answer shows in
# the seed, also when the block appends to the accumulator, leaves with
# `next`, or the seed is a frozen literal (it stays frozen). A block that
# answers a new String answers that String.
s2 = +"b"
t2 = [1].inject(s2) { |m, _| m }
p s2.equal?(t2)
t2 << "y"
p [s2, t2]
s3 = +"c"
t3 = [1, 2].inject(s3) { |m, x| m << x.to_s }
p s3.equal?(t3), s3
s4 = +"d"
t4 = [1, 2].inject(s4) { |m, x| m + x.to_s }
t4 << "!"
p s4, t4
u = "lit"
w = [1].reduce(u) { |m, _| m }
p w.equal?(u), w.frozen?
s5 = +"e"
t5 = [1, 2].inject(s5) { |m, x| next m if x > 1; m << "?" }
p s5.equal?(t5), s5
