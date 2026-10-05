# A boxed String's blockless each_codepoint materializes its codepoints as an
# Array, as each_char, each_line and each_byte do with their elements; those
# three had a with_index rewrite to chars/lines/bytes.each.with_index, and
# each_codepoint did not, so `.with_index` raised NoMethodError on the Array.
# did_you_mean's Levenshtein walks `str1.each_codepoint.with_index(1)`.
def walk(s)
  s.each_codepoint.with_index(1) { |c, i| print c, ":", i, " " }
  puts
end

boxed = ["héllo", 1][0]
walk(boxed)
walk("ab")
boxed.each_codepoint.with_index { |c, i| print c, "@", i, " " }
puts
boxed.each_byte.with_index(1) { |b, i| print b, ":", i, " " }
puts
p boxed.each_codepoint.to_a
