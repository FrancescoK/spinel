# Each receiver of a held chain runs once: a method that answers its
# argument counts its calls, and every shape below prints the count
# after it. A typed argument (`id`) and a boxed one (`bid`, which also
# takes an Integer) go through the two kinds of first link.
$n = 0
def id(v) = ($n += 1; v)
def bid(v) = ($n += 1; v)
bid(1)
def show(label) = p([label, $n])

s = +"ab"
t = s
id(s).upcase!.downcase!
id(s).upcase!.insert(0, "x")
id(s).downcase!.concat("1", "2")
id(s).upcase! << "3"
id(s).downcase!.setbyte(0, 65)
id(s).swapcase![1] = "Q"
id(s).upcase!.sub!("Q", "q")
id(s).downcase!.gsub!(/q/) { "w" }
id(s).upcase!.slice!(0)
id(s).downcase!.force_encoding("UTF-8")
id(s).upcase!.downcase!.force_encoding("UTF-8")
id(s).upcase!.append_as_bytes("z")
id(s).downcase!.bytesplice(0, 1, "Y")
p s, t
show(:typed_mutators)

r = id(s).upcase!.downcase!
p r, r.equal?(s)
p id(s).upcase!.equal?(t), t.equal?(id(s).downcase!)
p (+id(s).upcase!).equal?(t), (id(s).downcase! || s).equal?(t)
p id(s).upcase!.itself.equal?(t), id(s).downcase!.to_s.equal?(t), id(s).upcase!.to_str.equal?(t)
p id(s).downcase!.respond_to?(:upcase!)
o2 = +"ab"
p (id(o2).upcase!.downcase! || 1).equal?(o2), (id(o2).upcase! || 1).equal?(o2), (id(o2).downcase! && 1)
w = (id(o2).upcase!.downcase! || 1)
p w.equal?(o2)
def take(v, w = 0) = v
p take(id(o2).upcase!.downcase! || 1).equal?(o2), take(id(o2).upcase! || 1, 2), o2
show(:typed_values)

x = [s, 1]
bid(x[0]).upcase!.downcase!
bid(x[0]).upcase!.insert(0, "<")
bid(x[0]).downcase! << "!"
bid(x[0]).upcase!.concat(">")
bid(x[0]).downcase!.force_encoding("UTF-8")
p x, s
show(:boxed_mutators)

p bid(x[0]).upcase!.equal?(t), t.equal?(bid(x[0]).downcase!)
p bid(x[0]).upcase!.concat("!").equal?(x[0]), x[0].equal?(bid(x[0]).downcase!.concat("?"))
p bid(x[0]).upcase!.itself.equal?(t)
v = bid(x[0]).downcase!
p v.equal?(t)
s3 = +"ab"; x3 = [s3, 1]
p (bid(x3[0]).upcase!.downcase! || 1).equal?(s3)
show(:boxed_values)

y = [s, 1][0]
p y.equal?(bid(x[0]).upcase!.downcase!), y.equal?(bid(x[0]).upcase!)
show(:boxed_receiver)

nx = [[+"cd", 1], 2]
bid(nx[0][0]).upcase!
bid(nx[0][0]).downcase! << "!"
h = { a: [+"ef", 1] }
ha = h[:a][0]
bid(h[:a][0]).upcase!.concat("+")
p nx, h, ha
show(:nested)

z = [+"gh", +"ij"]
zy = z[0]
q = bid(z[0])&.upcase!&.downcase!
p q, z, zy
show(:safe_nav)
