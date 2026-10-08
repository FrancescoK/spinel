# Unary plus keeps a mutable element's handle and copies a frozen one.
words = %w[one two].map { |w| +w }
out = words.map { |w| w << "s"; w }
p words, out
s = +"x"; t = s; t << "y"
a = [s, 1].take(1).map { |w| +w }
a[0] << "!"
p s, a
p words.map { |w| w.frozen? }
