pr = proc { |c| print c, "," }
"xy".each_char(&pr); puts
"ab".each_byte(&pr); puts
"a\nb".each_line(&pr); puts
"a,b".each_line(",", &pr); puts
"hé".each_grapheme_cluster(&pr); puts
"a".upto("c", &pr); puts

l = ->(c) { print c.upcase }
p "zz".each_char(&l)
r = "ab".each_byte(&pr)
p r
m = method(:puts)
"mn".each_char(&m)
acc = []
ad = proc { |c| acc << c }
"uvw".each_char(&ad)
p acc

def fw(&b) = "xy".each_char(&b)
fw { |c| print c, ";" }; puts
def fwb(s, &b)
  s.each_byte(&b)
  nil
end
fwb("AB") { |c| print c, " " }; puts
def fwl(s, &b) = s.each_line(&b)
p(fwl("p\nq") { |c| print c.chomp, "|" })
def fwa(&) = "pq".each_char(&)
fwa { |c| print c, "!" }; puts
