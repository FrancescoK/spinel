# encode! that replaces characters gives the String new bytes, and every name
# for it sees them: a local's alias, a Hash value, an Array element, an
# instance variable read through attr_reader, a boxed value, the String the
# call answers. A String no other name sees is held by one variable, which
# takes the new bytes back. (Without --share-strings a String has no place
# to put new bytes that its other names would see, and raises
# NotImplementedError.)
def box(v) = [v, 1][0]

a = +"héllo"
b = a
r = a.encode!("BINARY", undef: :replace)
p [a, b, b.encoding.to_s, r.equal?(a)]
r << "!"
p a

h = { k: +"abé" }
h[:k].encode!("BINARY", undef: :replace, replace: "*")
p [h[:k], h[:k].encoding.to_s]

arr = [+"xyé"]
arr[0].encode!("BINARY", undef: :replace)
p [arr[0], arr[0].encoding.to_s]

s = +"h\xffllo"
t = s
s.encode!("UTF-8", invalid: :replace)
p [s, t, t.encoding.to_s]

s = "h\xffllo".b
t = s
s.encode!("UTF-8", undef: :replace, replace: "?")
p [s, t, t.encoding.to_s]

class Holder
  attr_reader :s
  def initialize = @s = +"héllo"
  def run = @s.encode!("BINARY", undef: :replace, replace: "*")
end
o = Holder.new
t = o.s
o.run
p [o.s, t, t.encoding.to_s]

x = box(+"héllo")
y = x
x.encode!("BINARY", undef: :replace)
p [x, y, y.encoding.to_s]

s = +"héllo"
r = s.encode!("BINARY", undef: :replace)
r << "!"
p [s, r.equal?(s)]
t = +"héllo"
t.encode!("BINARY", undef: :replace)
p t
$g = +"hé"
$g.encode!("BINARY", undef: :replace)
p $g
z = +"héllo"
[1].each { z.encode!("BINARY", undef: :replace) }
p z
w = +"héllo"
-> { w.encode!("BINARY", undef: :replace) }.call
p w
class Lone
  def initialize = @s = +"héllo"
  def run = (@s.encode!("BINARY", undef: :replace); @s)
end
p Lone.new.run
bx = box(+"héllo")
bx.encode!("BINARY", undef: :replace)
p bx
