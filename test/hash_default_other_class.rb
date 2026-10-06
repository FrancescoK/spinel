# Hash#default= with a default of another class than the Hash's values. A
# Hash whose values are all Integers or all Strings keeps them, and its
# default, in a typed slot, and the default was assigned there as it was: a
# Float was truncated, true read as 1 and a Symbol as its id, and a String
# or a boxed default did not build. CRuby answers the default for a missing
# key, so it is value evidence as a store is: the Hash's values widen for
# it, in a local, an instance, class or global variable, or a Hash a method
# answers. A default of the values' class keeps the typed Hash, and so does
# a nil literal, which a missing key answers anyway; a local that holds nil
# is boxed, so it widens the Hash as another class does. A boxed default
# given to a parameter's typed Hash, which is not widened, is unboxed as a
# boxed element store is: one of the values' class, or nil, is kept.

class C
  @@c = {"a" => 1}

  def initialize
    @h = {"a" => 1}
    @h.default = 1.5
  end

  def get(k) = @h[k]

  def self.go
    @@c.default = :none
    @@c["q"]
  end
end

def mk = {"a" => 1}

def seti(h, v)
  h.default = v
  h
end

def sets(h, v)
  h.default = v
  h
end

def t(k)
  h = {"a" => 1}
  h.default = 1.5
  p h["z"], h["a"]
  i = {1 => 2}
  i.default = true
  p i[9]
  s = {"a" => "x"}
  s.default = :sym
  p s["q"]
  b = {1 => 2}
  b.default = [true, 3][k]
  p b[9]
  m = mk
  m.default = 2.5
  p m["q"]
  n = {"a" => 1}
  n.default = 7
  p n["z"]
  p C.new.get("z"), C.go
  $g = {1 => "x"}
  $g.default = 4
  p $g[5]
  z = {"a" => 1}
  z.default = 3
  z.default = nil
  p z["q"], z.default
  x = nil
  w = {"a" => 1}
  w.default = 3
  w.default = x
  p w["q"], w.default
  e = seti({"a" => 1}, [7, "x"][k])
  p e["z"], e.default
  f = seti({"b" => 2}, [nil, "x"][k])
  p f["y"], f.default
  g = sets({1 => "b"}, ["d", 1][k])
  p g[9], g.default
  j = sets({2 => "c"}, [nil, 1][k])
  p j[8], j.default
end

t(ARGV.size)
