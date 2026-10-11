# A String mutator over a call that answers its receiver's String (a method
# handing back its argument, an append chain on one, a `&.` link) changes
# that String, and runs the call once
$n = 0
def id(x) = ($n += 1; x)
def show(x) = p(x)

# a `&.` chain as a statement
b = +"aab"; b2 = b
id(b)&.concat("1")&.<<("Z")
p [b2, $n]

# slice! after a chain of any length, and after a bang
$n = 0; b = +"aab"; b2 = b
v = id(b).concat("1").prepend("2").insert(0, "3").slice!(0)
p [v, b2, $n]
$n = 0; b = +"aab"; b2 = b
v = (id(b) << "1").slice!(0)
p [v, b2, $n]
$n = 0; b = +"aab"; b2 = b
v = id(b).upcase!.slice!(0)
p [v, b2, $n]
$n = 0; b = +"aab"; b2 = b
v = id(b)&.concat("1")&.slice!(0)
p [v, b2, $n]
$n = 0; b = +"aab"; b2 = b
show((id(b) << "1" << "2").slice!(1))
p [b2, $n]

# a bang, replace and setbyte after a chain of three and four links
$n = 0; b = +"aab"; b2 = b
(id(b) << "1" << "2" << "3" << "4").upcase!
p [b2, $n]
$n = 0; b = +"aab"; b2 = b
id(b).concat("1").prepend("2").insert(0, "3").sub!("a", "Q")
p [b2, $n]
$n = 0; b = +"aab"; b2 = b
(id(b) << "1" << "2" << "3").replace("RR")
p [b2, $n]
$n = 0; b = +"aab"; b2 = b
(id(b) << "1" << "2" << "3").setbyte(0, 90)
p [b2, $n]

# clear after a chain, as an argument and in an interpolation
$n = 0; b = +"aab"; b2 = b
show((id(b) << "1").clear)
p [b2, $n]
$n = 0; b = +"aab"; b2 = b
puts "<#{id(b).upcase!.clear}>"
p [b2, $n]

# setbyte's answer through a `&.` on the String
$n = 0; b = +"aab"; b2 = b; arr = [b]
v = id(b)&.setbyte(0, 90)
p [v, b2, $n]

# force_encoding on a call, as a value, an argument, an interpolation and a
# method's answer
$n = 0; b = +"aab"; b2 = b; arr = [b]
show(id(b)&.concat("1")&.force_encoding("ASCII-8BIT"))
p [b2, b2.encoding, $n]
$n = 0; b = +"aab"; b2 = b; arr = [b]
v = (id(b) << "1" << "2").force_encoding("ASCII-8BIT")
p [v, b2.encoding, $n]
$n = 0; b = +"aab"; b2 = b; arr = [b]
puts "<#{id(b).concat("1").force_encoding("ASCII-8BIT")}>"
p [b2.encoding, $n]
def fe(b) = id(b).concat("1").force_encoding("ASCII-8BIT")
$n = 0; b = +"aab"; b2 = b; arr = [b]
v = fe(b)
p [v, b2.encoding, $n]

# a `&.` mutator after a bang that answered nil is skipped, and runs on the
# String after one that changed it
$n = 0; b = +"AAB"; b2 = b
id(b).upcase!&.insert(0, "x")
p [b2, $n]
$n = 0; b = +"AAB"; b2 = b
id(b).upcase!&.clear
p [b2, $n]
$n = 0; b = +"AAB"; b2 = b
id(b).upcase!&.slice!(0)
p [b2, $n]
$n = 0; b = +"AAB"; b2 = b
id(b).upcase!&.setbyte(0, 90)
p [b2, $n]
$n = 0; b = +"AAB"; b2 = b
v = id(b).upcase!&.concat("Z")
p [v, b2, $n]
$n = 0; b = +"aab"; b2 = b
v = id(b).upcase!&.setbyte(0, 90)
p [v, b2, $n]
$n = 0; b = +"ab"; b2 = b
show(id(b).squeeze!&.replace("RR"))
p [b2, $n]

# `&.freeze` as a method's answer is the String, frozen
def tf(b) = id(b)&.freeze
def tbf(b) = id(b).upcase!&.freeze
$n = 0; b = +"aab"; b2 = b
v = tf(b)
p [v.equal?(b2), b2.frozen?, $n]
$n = 0; b = +"aab"; b2 = b
v = tbf(b)
p [v.equal?(b2), b2.frozen?, $n]
$n = 0; b = +"AAB"; b2 = b
v = tbf(b)
p [v, b2.frozen?, $n]
