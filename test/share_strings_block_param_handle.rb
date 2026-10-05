# A block parameter of a builtin's loop that the rule shares holds the
# String the loop binds, so an append through it reaches every name for it.
acc = []
"ab\ncd\n".each_line { |l| l.chomp!; acc << l; l << "!" }
p acc
chars = []
"xyz".each_char { |ch| chars << ch; ch << "+" }
p chars
words = %w[one two].map { |w| +w }
out = words.map { |w| w << "s"; w }
p words, out
sum = words.inject(+"") { |a, w| a << w }
p sum
