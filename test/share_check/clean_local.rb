# Strings no other name holds: nothing needs the handle, and nothing is
# reported.
a = +"one"
a << "!"
b = a + "?"
puts a, b
words = %w[x y z].map { |w| w.upcase }
puts words.join(",")
