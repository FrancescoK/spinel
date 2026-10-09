# spinel: share
# spinel: gc-minor
# spinel: gc-stress
# Each fresh setter result is the object retained as the Hash default.
def fresh_default_0
  s = +"src"
  h = {}
  t = (h.default = +"lit")
  t << "!"
  p t.equal?(h.default), h[:missing], t
  h.default << "?"
  p t, s
end
fresh_default_0

def fresh_default_1
  s = +"src"
  h = {}
  t = (h.default = s.upcase)
  t << "!"
  p t.equal?(h.default), h[:missing], t
  h.default << "?"
  p t, s
end
fresh_default_1

def fresh_default_2
  s = +"src"
  h = {}
  t = (h.default = s + "x")
  t << "!"
  p t.equal?(h.default), h[:missing], t
  h.default << "?"
  p t, s
end
fresh_default_2

def fresh_default_3
  s = +"src"
  h = {}
  t = (h.default = s.dup)
  t << "!"
  p t.equal?(h.default), h[:missing], t
  h.default << "?"
  p t, s
end
fresh_default_3

def fresh_default_4
  s = +"src"
  h = {}
  t = (h.default = String.new(s))
  t << "!"
  p t.equal?(h.default), h[:missing], t
  h.default << "?"
  p t, s
end
fresh_default_4

def fresh_default_5
  s = +"src"
  h = {}
  t = (h.default = "#{s}y")
  t << "!"
  p t.equal?(h.default), h[:missing], t
  h.default << "?"
  p t, s
end
fresh_default_5

def fresh_default_6
  s = +"src"
  h = {}
  t = (h.default = s * 2)
  t << "!"
  p t.equal?(h.default), h[:missing], t
  h.default << "?"
  p t, s
end
fresh_default_6

def fresh_default_7
  s = +"src"
  h = {}
  t = (h.default = s[0, 2])
  t << "!"
  p t.equal?(h.default), h[:missing], t
  h.default << "?"
  p t, s
end
fresh_default_7

# The store row also covers Array#[]=, Hash#[]= and Hash#store results.
a = []
t = (a[0] = +"array")
t << "!"
p a, t.equal?(a[0])
h = {}
u = (h[:x] = +"hash")
u << "!"
p h, u.equal?(h[:x])
v = h.store(:y, +"store")
v << "!"
p h, v.equal?(h[:y])

# A dropped fresh setter value still leaves the default mutable through its Hash.
h = {}
h.default = +"dropped"
h.default << "!"
p h[:missing]
h[:missing] << "?"
p h.default
