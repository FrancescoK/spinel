# s[i] on byte-indexed text reads the byte at i
# A String proved 7-bit, or a BINARY one, answers s[i] from the byte at i
# without counting characters; one that holds a multibyte character, or
# that gains one, counts them as before.

s = "template {{x}} text"
s.size
p s[0], s[9], s[-1], s[-19], s[19], s[-20], s[100]
out = +""
i = 0
while i < s.size
  out << s[i].upcase if s[i] =~ /[a-z]/
  i += 1
end
p out

b = "\xff\x00A\x80".b
p b[0], b[1], b[2], b[3], b[4], b[0].encoding, b[2].encoding

z = "a\0b"
p z[1], z[1].size, z[2]

g = +"abc"
g.size
p g[2]
g << "déf"
p g[3], g[4], g[5], g[-1], g.size
g << "!"
p g[-1], g[6]

e = ""
p e[0], e[-1]
t = :symbol.to_s
p t[0], t[-1]
