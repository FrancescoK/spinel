# `s || nil` (or `s || "lit"`) of a String parameter, stored where the
# chain's value is a handle: the other arm stayed nil's `(0, NULL)` or the
# literal's bytes, the conditional became a void *, and the store read the
# handle pointer as bytes -- garbage in the Array, and not s itself.
def t(s)
  a = [(s || nil)]
  p a, a[0].equal?(s)
end
t(+"s")
def u(s)
  a = [(s || "o")]
  p a, a[0].equal?(s)
end
u(+"v")
def w(s)
  a = [(s && "z")]
  p a
end
w(+"q")
def x(s)
  h = { k: (s || nil) }
  h[:k] << "!"
  p h, s
end
x(+"m")
