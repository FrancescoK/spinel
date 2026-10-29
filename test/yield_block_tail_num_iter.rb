# A yielded block whose last expression is a counting iterator on a value
# that is not a plain local read: CRuby's times, upto, downto and step
# answer their receiver, and the block answers that. The block answered 1
# (the loop's signal counter) or 1.0 instead.
def t = yield
def four = 4
p t { 2.times { } }
p t { 3.times { |i| i + 1 } }
p t { 2.upto(3) { } }
p t { 5.downto(3) { } }
p t { four.times { } }
p t { (four + 1).times { } }
p t { 1.step(5, 2) { } }
p t { 1.5.step(3.0, 0.5) { } }
x = t { 6.times { } }
p x
def u; yield; end
p u { 4.times { } }
n = 3
p t { n.times { } }
p t { 2.times { n += 1 } }
p n
