# An index operator-write (`t[k] += 1`, `-=`, `||=`) on a parameter a caller
# hands a boxed Hash.new(default): the body typed the parameter from the write
# alone, so the call converted a copy, which lost the default ("undefined
# method '+' for nil") and kept the writes from reaching the caller's hash
def look(t, k)
  t[k]
end

def inc(t)
  t["a"] += 1
end
h = Hash.new(0)
inc(h)
inc(h)
p h
p look(h, "missing")

def dec(t)
  t[:n] -= 2
end
s = Hash.new(10)
dec(s)
dec(s)
p s
p look(s, :other)

def fill(t)
  t["k"] ||= "first"
end
f = Hash.new(false)
fill(f)
fill(f)
p f

def cat(t, x)
  t["s"] += x
end
c = Hash.new("")
cat(c, "ab")
cat(c, "cd")
p c
p look(c, "none")
