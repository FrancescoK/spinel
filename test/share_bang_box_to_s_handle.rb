# A bang's to_s on a boxed receiver is the box's String, which the bang
# changed, or, where the bang changed nothing (nil), a frozen "": a
# variable that takes it and changes it in place changes the box's String.
# It was refused as a route that cannot carry the handle (#9258).
s = [+"kl", 1].first
t = s.upcase!.to_s
t << "!"
p t, s
u = [+"MN", 1].first
v = u.upcase!.to_s
p v, v.frozen?
w = [+"ab", 2].first
x = w.downcase!.to_s
x << "?" unless x.frozen?
p x, w
