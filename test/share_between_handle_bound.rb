# spinel: share
# A shared String (under --share-strings, a String reached through a
# container and grown in place) is a String to the boxed String check:
# between? with one as a bound raised "comparison of String with String
# failed", and casecmp / casecmp? answered nil.
def grow(s)
  s << ""
  s
end
hs = [+"zz"]
ls = [+"a"]
ms = [+"m"]
hi = grow(hs[0])
lo = grow(ls[0])
mm = grow(ms[0])
s = +"m"
r = []
i = 0
while i < 50
  r << (s + i.to_s).between?(lo, hi)
  r << (s + "q").between?("a" + i.to_s, hi)
  i += 1
end
p r.count(true), r.count(false)
p "n".between?(lo, mm), "b".between?(lo, hi)
p "M".casecmp(mm), "M".casecmp?(mm)
p "b" < hi, "b" >= lo, ("b" <=> hi)
hi << "z"
p "zzz".between?(lo, hi), "zzzz".between?(lo, hi)
