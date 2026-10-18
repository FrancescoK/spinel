# A local bound to the Array lines, scan or chars answers (or its to_a),
# whose Strings an each block mutates in place and that is read
# afterwards: each keeps the elements, so the mutation must be seen through
# the Array. Refused, as for split, not silently applied to a copy.
lines = "a\nb\n".lines.to_a
lines.each { |line| line.chomp!("\n") }
p lines
