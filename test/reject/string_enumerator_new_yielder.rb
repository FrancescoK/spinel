# Enumerator.new's yielder hands next s itself. The answer was a copy and s
# stayed "abc": refused, not compiled wrong.
s = +"abc"
e = Enumerator.new { |y| y << s }; r = e.next
r << "!"
p s
p r
