# A String built in a method's own locals and returned is the caller's own
# (`out = +""; out << x; out`): under --share-strings the return hands it
# over rather than sharing it, unless the method also gave it another name
# (an alias, an ivar, a parameter, a container) before returning it.

def build1(n)
  out = +""
  n.times { |i| out << i.to_s }
  out
end

def build2
  s = +"a"
  t = s
  t << "b"
  s
end

def build3
  s = +"k"
  @keep = s
  s << "1"
  s
end

def build4(x)
  x << "!"
  x
end

def build5
  a = []
  s = +"e"
  a << s
  a
end

r1 = build1(5); r1 << "z"
r2 = build2; r2 << "c"
r3 = build3; r3 << "2"
x = +"p"; r4 = build4(x); r4 << "?"
r5 = build5; r5[0] << "!"
p r1, r2, r3, @keep, x, r4, r5

# A discarded conditional's last call, or one in parentheses, keeps nothing:
# `p r1, r2` there joins neither, and a dropped build's String is its own.
if r1.size > 0
  p r1, r2
end
(build1(1)) if r1
r6 = build1(2)
r6 << "y"
p r6, r1, r2
