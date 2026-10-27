# A blockless sort_by on an integer Range answers an Enumerator over the
# range's elements, as select and reject on a Range do.

p (10..11).sort_by.to_a
p (10...13).sort_by.entries
p (10..11).sort_by.to_a { |x| -x }
p (10..11).sort_by.size

e = (1..3).sort_by
p e.class
p e.to_a
p e.each { |x| -x }
p (1..3).sort_by.with_index { |x, i| -i }
p (1..3).sort_by { |x| -x }
