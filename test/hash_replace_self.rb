# Hash#replace with the receiver itself keeps its entries, as in CRuby. The
# String=>String, Integer=>String, String=>poly and Symbol=>poly tables
# cleared the receiver before copying from the argument, so a hash replaced
# by itself came back empty. Each hash has its own local so it keeps its own
# table kind.
ss = {"a" => "b", "c" => "d"}
ss.replace(ss)
p ss
is = {1 => "a", 2 => "b"}
is.replace(is)
p is
sp = {"a" => 1, "b" => "x"}
sp.replace(sp)
p sp
yp = {a: 1, b: "x"}
yp.default = 7
yp.replace(yp)
p [yp, yp[:zz]]
