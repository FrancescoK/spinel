# Each receiver of a held chain runs once: a method that answers its
# argument counts its calls, and every shape below prints the count
# after it.
$n = 0
def id(v) = ($n += 1; v)
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
