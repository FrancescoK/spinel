# The empty hash of a nil-guard fallback (`x || {}`, `x || Hash.new`) takes
# its variant from the keys later written into the slot, as a bare `{}`
# does. It was always the String-keyed hash, so a Symbol key raised
# TypeError or was stored as a String.
h = nil || {}
h[:k] = 2
p h

h2 = nil || Hash.new
h2[:k] = 2
p h2

h3 = nil || {}
h3[:a] = 1
h3["b"] = 2
p h3

h4 = nil || {}
h4[3] = 4
p h4

def f(x)
  h = x || {}
  h[:k] = 2
  h
end
p f(nil)

def g(x)
  h = x || Hash.new
  h[:k] = 2
  h
end
p g(nil)

def opt(o = nil)
  o = o || {}
  o[:x] = 1
  o
end
p opt

class C
  def initialize
    @h = nil || {}
  end

  def go
    @h[:a] = 1
    p @h
  end
end
C.new.go

class D
  def initialize
    @h = nil || {}
  end

  def go
    @h[:a] = 1
    @h["b"] = 2
    p @h
  end
end
D.new.go

class E
  def go
    @h ||= Hash.new
    @h[:k] = 1
    p @h
  end

  def go2
    @i ||= Hash.new
    @i[3] = 1
    p @i
  end
end
E.new.go
E.new.go2

$g = nil || {}
$g[:k] = 1
p $g

class F
  @@h = nil || {}
  def go
    @@h[:k] = 1
    p @@h
  end
end
F.new.go

h5 = nil || {}
h5[:k] ||= 0
h5[:k] += 5
p h5
