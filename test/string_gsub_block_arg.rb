pr = proc { |m| m.upcase }
p "abc".gsub("b", &pr)
p "abc".sub("b", &pr)
p "abcb".gsub(/b/, &pr)
s = +"xbx"
s.gsub!("b", &pr)
p s
t = +"xbx"
p t.sub!(/b/, &pr)
p t.sub!(/q/, &pr)
l = ->(m) { "<#{m}>" }
p "aXa".gsub("a", &l)
p "abc".gsub("b", "X", &pr)
cnt = 0
co = proc { |m| cnt += 1; m * cnt }
p "aaa".gsub("a", &co)
def fw(s, &b) = s.gsub(/[ab]/, &b)
p fw("abc") { |m| m.ord.to_s }
