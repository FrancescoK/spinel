# `each { }` on a boxed Enumerator answers what the Enumerator's own method
# answers: the collection an `each` Enumerator was made from, not the
# Enumerator. (A blockless collector's -- map, select, ... -- each with a
# block raises NotImplementedError instead of answering the Enumerator.)
y = [[1, 2].each, 2][0]
p y.each { |v| v * 10 }
h = [{ a: 1 }.each, 2][0]
p h.each { |k, v| v }
s = [(1..3).each, 2][0]
p s.each { |v| v }
