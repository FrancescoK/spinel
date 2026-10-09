s = +"abc"
e = Enumerator.new { |y| y << s }; r = e.next
r << "!"
p s
p r
