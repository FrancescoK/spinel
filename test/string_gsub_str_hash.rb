# gsub with a String pattern and a Hash replaces every occurrence with the
# hash's value for the matched text ("" when the hash lacks it) and leaves
# $~ at the last occurrence, as sub with a Hash does for the first.
s = "Hello World, Hello"
h = {"Hello" => "Bye", "o" => "0"}
p s.gsub("Hello", h), s.gsub("o", h), s.gsub("zz", h), s.gsub("l", h)
p "aaa".gsub("a", "a" => "bb"), "aaaa".gsub("aa", "aa" => "x")
p "hello".gsub("", "" => "-"), "".gsub("", "" => "x")
s.gsub("Hello", h)
p $~[0], $~.pre_match.size
s.gsub("zz", h)
p $~
t = "Hello"
p t.sub("l", h), t.gsub("l", {"l" => "L"})
