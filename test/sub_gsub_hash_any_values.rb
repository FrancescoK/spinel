# sub and gsub (and their bang forms) take a String-keyed Hash of any
# values as the replacement, each value read with to_s (nil as ""), with a
# String or Regexp pattern, as CRuby does.
h = {"o" => "0", "l" => nil}
n = {"o" => 0, "l" => 1}
y = {"o" => :zero, "l" => 1.5}
p "foo".sub("o", h), "foo".gsub("o", h), "hello".gsub("l", h), "hello".gsub(/l/, h)
p "foo".gsub("o", n), "hello".sub(/l+/, n), "hello".gsub(/[lo]/, n)
p "foo".sub(/o/, y), "hello".gsub("l", y), "hello".gsub("z", y)
r = /l/
p "hello".gsub(r, n), "hello".sub(r, h)
p "hello".gsub("l", h), $~ && $~[0]
s = +"hello"
s.gsub!("l", n)
p s
t = +"hello"
p t.sub!(/l/, y), t
