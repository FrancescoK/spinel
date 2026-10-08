# Both mutators answer the receiver, including when an argument rebinds it.
s = +"a\0b"
alias_s = s
r = s.insert(1, "x" * 100)
p [r.equal?(s), r.equal?(alias_s), r.bytesize, r.getbyte(102)]
s = +"next"
r << "!"
p [alias_s.bytesize, s]

t = +"before"
alias_t = t
r = t.replace("new\0" * 30)
p [r.equal?(t), r.equal?(alias_t), r.bytesize]
r << "!"
p [alias_t.bytesize, alias_t.getbyte(3)]

u = +"old"
a = u
r = u.insert(0, (u = +"new"))
p [r, u, r.equal?(a)]
v = +"old"
b = v
r = v.replace(v = +"new")
p [r, v, r.equal?(b), r.equal?(v)]

begin
  "frozen".insert(0, "x")
rescue FrozenError
  puts "insert frozen"
end
begin
  "frozen".replace("x")
rescue FrozenError
  puts "replace frozen"
end
