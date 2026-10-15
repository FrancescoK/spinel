# spinel: share
# spinel: gc-minor
# A constant named to const_get with leading colons (::L): the Array it holds
# keeps the general form.
L10 = [+"s"]
def add10(t) = L10 << t
add10(+"u")
x10 = Object.const_get("::L10")
x10 << +"v"
p L10, x10.size

# beside it an Array nothing here touches keeps the handle form
u = +"u"
plain = [u, +"o"]
plain << +"p"
plain.each { |e| e << "." }
u << "?"
p plain, u
