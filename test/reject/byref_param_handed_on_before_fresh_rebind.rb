# A parameter handed to a mutating call before the method rebinds it to a
# fresh String is still the caller's String there: the method lends it, and
# a caller that passes its own parameter on and rebinds it from the result
# stays refused.
def grow(t) = t << "!"
def ident(t) = t

def normalize(s)
  grow(s)
  s = s.dup
  grow(s)
  s
end

def outer(text)
  text = normalize(text)
  text = ident(text)
  text
end

x = +"a"
p outer(x), x
