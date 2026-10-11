# An append chain over a bang that answers its receiver or nil, on a
# variable's String: nil when the bang changed nothing and every link is a
# safe navigation, NoMethodError when a plain link meets that nil (also past
# a safe link), else the variable's String itself, appended in place, which
# every name sees, answers equal? true and is frozen through every name; as
# a value, a statement, an Array element and a method's value, with a concat
# of several Strings among the links and a receiver that runs once.
s = +"s"
t = s
r = s.sub!("zz", "y")&.<<("!")
p r, s, t
r = s&.sub!("s", "y")&.<<("!")&.<<("?")
p r, s, t, r.equal?(t)
s.upcase!&.<<("1")
p s, t
begin
  r = s.sub!("zz", "y") << "!"
rescue NoMethodError => e
  p e.class
end
r = s.sub!("Y", "z") << "2"
p r, s, t, r.equal?(s)
u = +"uu"
k = [u]
r = u.squeeze!&.<<("5")
p r, u, k, r.equal?(u)
r.freeze
p u.frozen?, k[0].frozen?
v = +"v"
begin
  v.sub!("zz", "y")&.<<("1").<<("2")
rescue NoMethodError => e
  p e.message[0, 30]
end
r = v.sub!("v", "y")&.<<("1").<<("2")
p r, v
x = [v.sub!("zz", "q")&.<<("3"), v.sub!("y", "z")&.<<("4")]
p x, x[1].equal?(v)
def strip_tail(x) = x.strip!&.<<("6")
w = +" w "
r = strip_tail(w)
p r, w, r.equal?(w)
# a concat of several Strings after the bang, a receiver counted to run once
cc = +"ccc"
r = cc.squeeze!&.concat("3", "4")
p r, cc, r.equal?(cc)
p cc.squeeze!&.concat("5", "6")
dd = +"dd"
dd.squeeze!&.concat("7", dd)&.<<("8")
p dd
$n = 0
def counted(x) = ($n += 1; x)
ee = +"ee"
counted(ee).squeeze!&.concat("a", "b")&.<<("c")
r = counted(ee).sub!("e", "E")&.<<("1").<<("2")
p ee, r, $n
