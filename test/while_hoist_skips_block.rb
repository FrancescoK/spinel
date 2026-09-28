# A while condition whose block reads the block parameter's size reads it
# on every call, not once before the loop.
a = ["a", "bb", "ccc"]
i = 0
while a.count { |x| x.size > i } > 1
  i += 1
end
p i
j = 0
j += 1 until a.all? { |s| s.length > j } == false
p j
s = "abcd"
k = 0
k += 1 while k < s.length
p k
# a lambda's parameter the same way
m = 0
m += 1 while ->(x) { x.size }.call(s) > m
p m
# a String the condition itself changes is read on every turn
t = String.new("ab")
n = 0
n += 1 while (t << "x"; t.length < 6)
p [n, t]
# so is one the condition's block reassigns
u = "ab"
w = "abcdefgh"
q = 0
q += 1 while [w].any? { |x| u = x if q == 1; w.length > q } && q < u.length
p [q, u]
