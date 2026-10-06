# Thread#value answers the block's value, here s itself, so r is s. The
# answer was a copy and s stayed "abc": refused, not compiled wrong.
s = +"abc"
r = Thread.new { s }.value
r << "!"
p s
