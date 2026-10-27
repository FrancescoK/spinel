# The right side of `||` and `&&` runs only if the left decides so: a global it
# writes is nil until then, and a loop that reads it before sees nil.
ARGV.empty? || ($g = 1)
t = 0
3.times { t += 1 if $g.nil? }
p t
p $g
ARGV.empty? && ($h = 2)
p $h
ARGV.empty? || ($k = 3)
p $k
