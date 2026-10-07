# Flag-only. A method that answers one of its parameters on some path hands
# the caller's String back: the name the answer is written to, or the
# String mutator called on it, names the caller's String. A tail that is a
# conditional (a ternary, an elsif chain, `unless`/`else`, a modifier `if`
# whose other path answers nil) now publishes the handle each arm reads, so
# the call hands it on, where the flag used to refuse these. A nil arm
# answers nil, even when the method read the handle before. Each case runs
# in a method of its own, with methods of its own.
def choose_a(x, y, f) = f ? x : y
def ternary_write
  s = +"abc"
  t = choose_a(+"unused", s, false)
  t << "!"
  p s, t
end
ternary_write

def choose_b(x, y, f) = f ? x : y
def ternary_receiver
  u = +"u"
  choose_b(u, +"v", true) << "?"
  p u
end
ternary_receiver

def pick3(a, b, c, k)
  if k == 0
    a
  elsif k == 1
    b
  else
    c
  end
end
def elsif_chain
  a = +"a"
  b = +"b"
  w = pick3(+"x", b, a, 2)
  w << "2"
  p a, b, w
end
elsif_chain

def unless_else(x, y, f)
  unless f
    x
  else
    y
  end
end
def unless_arm
  q = +"q"
  r = unless_else(+"z", q, true)
  r << "u"
  p q
end
unless_arm

def maybe(s, flag)
  if flag
    s
  end
end
def nil_arm
  m = +"m"
  n = maybe(m, true)
  n << "!"
  p m
  z = maybe(m, false)
  p z
end
nil_arm

# the read before the conditional publishes the handle; the nil arm still
# answers nil
def maybe_read(s, flag)
  print s, "\n"
  s if flag
end
def nil_arm_after_read
  k = +"k"
  o = maybe_read(k, false)
  p o
  o = maybe_read(k, true)
  o << "+"
  p k
end
nil_arm_after_read

def early(s, flag)
  return s if flag
  nil
end
def early_return
  e = +"e"
  r = early(e, true)
  r << "1"
  p e
  p early(e, false)
end
early_return

def nested(x, y, f, g)
  f ? (g ? x : y) : nil
end
def nested_ternary
  e = +"e"
  h = nested(+"n", e, true, false)
  h << "#"
  p e
  p nested(e, e, false, true)
end
nested_ternary
