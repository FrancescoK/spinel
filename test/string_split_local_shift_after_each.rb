# A local bound to split's Array whose Strings an each block strips in
# place, then shifted afterwards: shift hands out a String each mutated,
# so the mutation must be seen through the Array. Still refused, not
# silently applied to a copy.
a = " x , y ".split(",")
a.each { |s| s.strip! }
p a.shift
