# patch answers its parameter through bytesplice, so w is data itself, and
# data is the String the caller passed in and reads again. The result is a
# copy today, so an append through w would not reach s (CRuby "Zbc!", Spinel
# "Zbc"): refused, as a method returning `x.strip!` is.
def patch(x) = x.bytesplice(0, 1, "Z")
def entry(data)
  w = patch(data)
  w << "!"
end
s = +"abc"
entry(s)
p s
