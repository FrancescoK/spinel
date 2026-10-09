# zip reads a Range argument only as far as its receiver reaches, so an
# infinite one stops there as in CRuby. spinel materialized the whole range
# first: `10.upto(Float::INFINITY)` took a 2**30-element array (seconds of
# run time), and its bound was a cast of Infinity to an Integer.
p [1, 2].zip(10.upto(Float::INFINITY))
p [1, 2].zip(1..)
p [1, 2, 3].zip(5..6)
p %w[a b].zip(3.upto(2.5), 0...9)
p 1.upto(2.5).to_a, 3.downto(1.5).to_a
