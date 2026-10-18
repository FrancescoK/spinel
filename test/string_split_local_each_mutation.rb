# A local bound to split's Array whose Strings an each block strips in
# place, and that is read afterwards: each keeps the elements, so the
# mutation must be seen through the Array. Still refused, not silently
# applied to a copy.
a = " x , y ".split(",")
a.each(&:strip!)
p a
