# spinel: int64
# A row holding an Integer literal past 64 bits is a general Array as well,
# and the fold over the literal table read it as an Integer Array.
p [[1], [9223372036854775808]].inject([]) { |m, v| m + v }
p [[1, 2], [9223372036854775808]].inject(0) { |n, v| n + v.size }
p [[9223372036854775808], [1]].inject(&:|)
p [[1], [9223372036854775807]].inject([]) { |m, v| m + v }
