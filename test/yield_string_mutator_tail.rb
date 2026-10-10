# A block that ends with concat, replace, insert or prepend on a String
# answers that String, kept or passed on by the method that yields (#8400).
def keep
  yield
end

buf = +"k"
v = keep { buf.concat("a") }
p buf, v
a = +"m"
p keep { a.replace("r") }, a
b = +"n"
p keep { b.insert(0, "i") }, b
d = +"o"
p keep { d.prepend("p") }, d
e = +"q"
p keep { e.concat("1", "2") }, e
