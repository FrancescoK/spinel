# A program that requires stringio and calls each_byte/each_char on a
# boxed String gets only the String arms: StringIO is never constructed,
# so its Ruby-side each_byte/each_char add no arm (#9931).
require "stringio"
x = [+"ab", 1].first
p x.each_byte.to_a
p x.each_char.to_a
e = x.each_char
p e.next
p x.each_grapheme_cluster.to_a
