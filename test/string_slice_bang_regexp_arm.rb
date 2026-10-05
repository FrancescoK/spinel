# The first Regexp slice! arm supplies the removed match and the remainder.
s = +"ab12cd34"
p s.slice!(/\d+/)
p s
p $~[0]
p s.slice!(/z+/)
p s
p $~
begin
  "ab12".slice!(/\d+/)
rescue => e
  p e.class
end
