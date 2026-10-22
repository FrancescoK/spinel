# A split with limit 1 searches nothing, so an invalid UTF-8 String is not
# refused, as CRuby's is not; and a byte written over a String whose length
# was asked makes the next search see the invalid byte, the character count
# of the old bytes no longer vouching for them.
s = String.new("a\xff,b")
p s.split(/,/, 1)
p s.split(",", 1)
t = "é".dup
p t.length
t.setbyte(1, 255)
begin
  p t =~ /x/
rescue ArgumentError => e
  p e.class
end
begin
  p t.split(/,/)
rescue ArgumentError => e
  p e.class
end
