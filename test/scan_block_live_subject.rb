# scan with a block searches the subject as it is each turn: $~ is that
# turn's match, and a turn that changes the subject's length raises
s = +"a1b2c3"
r = s.scan(/([a-z])(\d)/) { |l, d| print l, d, " ", $~[0], " ", $1, "\n" }
p r
s.scan(/([a-z])(\d)/) { |row| p row }
s.scan(/[a-z]/) { |m| p [m, $~[0]] }
t = +"xyz"
t.scan(/(.)/) { |c| t.upcase! if c == ["x"]; p c }
u = +"abab"
begin
  u.scan(/(a)(b)/) { |x, y| u << "q" }
rescue => e
  p e.message, $~[0]
end
p "k1k2".scan(/k(\d)/) { }
v = +"pq"
w = [v, 1][ARGV.size]
acc = []
begin
  w.scan(/./) { |m| acc << m; v << "r" }
rescue RuntimeError => e
  p e.message
end
p acc, v
# a scan that matches nothing leaves $~ nil
h = +"hello"
h.scan(/l/) { }
h.scan(/zz/) { }
p $~
h.scan(/(z)/) { }
p $~
h.scan(/(l)/) { }
p $~[0]
