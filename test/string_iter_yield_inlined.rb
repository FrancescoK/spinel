# A yielding method whose `yield` sits inside a String iterator's block
# (`@s.each_char { |ch| yield ch }`, each_byte, each_line), inlined at its
# call site: the iterator emitted its block body with the inline's local
# renames switched off, so the yield argument read the callee's block
# parameter under its unrenamed name, which nothing declares (a C error).
# Array#each and the other iterators kept the renames on.
class Word
  def initialize(s) = @s = s
  def each_letter = @s.each_char { |ch| yield ch }
  def each_code = @s.each_byte { |bt| yield bt }
  def each_row = @s.each_line { |ln| yield ln.chomp }
  def letters = @s.chars { |ch| yield ch }
end
w = Word.new("ab\ncd\n")
w.each_letter { |ch| print ch.inspect, " " }
puts
r = w.each_letter { |ch| print ch.ord, " " }
puts
p r
p(w.each_code { |bt| print bt, " " })
w.each_row { |ln| print "[", ln, "]" }
puts
x = [w, nil].first
q = x.each_row { |ln| print "<", ln, ">" }
puts
p q
p(w.letters { |ch| print ch })
