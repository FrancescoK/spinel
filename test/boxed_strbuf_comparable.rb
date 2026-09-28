# A String built in place and read out of a container answers
# is_a?(Comparable), kind_of?(Comparable), `when Comparable` and
# `in Comparable` as a plain String there does; a builder slot that holds
# nil does not.
s = +"ab"
s << "c"
x = [s, 1][0]
p x.is_a?(Comparable)
p x.kind_of?(Comparable)
p(case x; when Comparable then :cmp; else :no; end)
p(case x; in Comparable then :cmp; else :no; end)
p ["abc", 1][0].is_a?(Comparable)
p [s, :t, 2, nil].map { |v| v.is_a?(Comparable) }
y = +"a"
y << "b"
y = nil
p [y, 1][0].is_a?(Comparable)
