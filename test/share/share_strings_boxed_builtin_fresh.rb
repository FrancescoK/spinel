# A boxed receiver's call of a name only String, IO and the scalars have
# (`x.tr`, `x.squeeze`), which no class of the program defines, answers a
# new String, or raises NoMethodError: no other name holds what it answers.
# Kept beside a String changed through another name, it is a new handle
# around its bytes, and a change through it shows through its other names
# but leaves the receiver alone.
$all = []
buf = +"buf"
$all << buf
buf << "!"

def norm(x)
  y = x.tr("-", "_")
  $all << y
  y
end
s = +"a-b"
r = norm(ARGV.size > 0 ? 1 : s)
r << "?"
s << "!"
p r, s

x = ARGV.size > 0 ? 1 : +"  Orig-x "
z = x.squeeze
$all << z
z << "."
c = x.tr_s("O", "0").chomp(" ")
$all << c
c << "."
p x, z, c

p $all
