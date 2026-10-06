# A Hash.new block answering s makes s itself what a missing key reads.
# The read was a copy and s stayed "abc": refused, not compiled wrong.
s = +"abc"
h = Hash.new { |hh, k| s }
r = h[:missing]
r << "!"
p s
