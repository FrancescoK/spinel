# String#index / #rindex whose pattern is a Regexp or a String only at run
# time (an element of a mixed array): the search follows the pattern's
# class, with or without a start. The String conversion took the Regexp
# and raised TypeError.
a = [/b/, "c", nil]
s = "abcb"
p s.index(a[0])
p s.index(a[1])
p s.rindex(a[0])
p s.rindex(a[1])
p s.index(a[0], 2)
p s.rindex(a[0], 2)
p s.index(a[1], 3)
p s.rindex(a[1], 1)
begin
  s.index(a[2])
rescue TypeError => e
  p e.message
end
a.first(2).each { |pat| p "xbxc".index(pat) }
