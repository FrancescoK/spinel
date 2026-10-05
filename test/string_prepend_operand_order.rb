# Unbound prepend operands run left to right, including their hoisted code.
s = +"a"
2.times { s << "!" }
i = 0
p (s).prepend((i += 1; i.to_s), ([i += 1].first.to_s))
p i
p s

i = 0
p (s).prepend((i += 1; i.to_s), (i += 1; i.to_s), (i += 1; i.to_s))
p i

def part(n)
  p n
  n.to_s * 100
end
p (s).prepend((part(4)), (part(5))).size
