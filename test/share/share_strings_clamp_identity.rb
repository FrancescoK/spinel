# A String clamp whose answer is changed in place shares its operands'
# Strings: the answer is the receiver, min or max object itself, and every
# identity question asked of a clamp answers that operand (equal? on either
# side, against a variable, a method's answer or another clamp, and
# object_id), with the bounds as two arguments, a Range literal or a Range
# held in a variable.

lo = +"b"; hi = +"y"; s = +"m"
c = "a".clamp(lo, hi)
c << "!"
p [lo, c.equal?(lo), lo.equal?(c)]
p ["a".clamp(lo, hi).equal?(lo), lo.equal?("a".clamp(lo, hi))]
p ["z".clamp(lo, hi).equal?(hi), s.clamp(lo, hi).equal?(s)]
p "a".clamp(lo, hi).object_id == lo.object_id
p ["a".clamp(lo..hi).equal?(lo), "z".clamp(lo..hi).equal?(hi)]
p "a".clamp(lo, hi).equal?("a".clamp(lo, hi))
def same_string(x) = x
p ["a".clamp(lo, hi).equal?(same_string(lo)), same_string("a".clamp(lo, hi)).equal?(lo)]

# a Range held in a variable keeps its endpoints' Strings
lo = +"b"; hi = +"y"; r = lo..hi
c = "a".clamp(r)
c << "!"
p [lo, r, c.equal?(lo)]
p "z".clamp(r).equal?(hi)
s = +"m"
p s.clamp(r).equal?(s)
e = s.clamp(r)
e << "?"
p s
begin
  "m".clamp(lo...hi)
rescue ArgumentError => x
  p x.message
end
r2 = lo...hi
begin
  "m".clamp(r2)
rescue ArgumentError => x
  p x.message
end
r3 = (lo..)
p ["a".clamp(r3).equal?(lo), "z".clamp(r3)]
r4 = (..hi)
p "z".clamp(r4).equal?(hi)

# frozen literal endpoints are answered frozen
r5 = "b".."y"
f = "a".clamp(r5)
p f.frozen?
begin
  f << "!"
rescue FrozenError => x
  p x.class
end
s = +"m"
t = s.clamp(r5)
t << "!"
p s
