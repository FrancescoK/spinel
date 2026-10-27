# A Hash subclass's new with a default or a block makes an instance of
# the class whose Hash has that default, whatever the class's other
# stores put in its Hash (a Symbol key, a String key).
class H < Hash; end
h = H.new
h[:a] = 1
x = H.new(7)
p x[:zz]
p x.class
p x.default
y = H.new { |hh, k| hh[k] = k.to_s * 2 }
p y[:ab]
p y
z = H.new(nil)
p z[:w]
h.replace({"s" => 2})
p h
p h.class

class C < Hash; end
c = C.new(0)
c["a"] += 1
c["a"] += 1
p c
p c["none"]

class D < C; end
d = D.new(5)
d["k"] = 1
p d["q"]
p d.class

class S < Hash; end
s = S.new
s[1] = "one"
t = S.new("dflt")
p t[2]
t2 = S.new { |_, k| "k#{k}" }
p t2[9]
p S.new(3).size

# a class's own replace is not called by new
class R < Hash
  def replace(o)
    puts "own replace"
    super
  end
end
r = R.new(7)
p r[:x]
r[:a] = 1
p r

class RA < Array
  def replace(o)
    puts "own replace"
    super
  end
end
p RA.new(2, 0)

# replace with another Hash subclass's instance of another kind
class P < Hash; end
class Q < Hash; end
pp1 = P.new
pp1[:a] = 1
q = Q.new
q["x"] = "y"
pp1.replace(q)
p pp1, pp1.class, pp1["x"]
pp1[:n] = 5
p pp1[:n] + 1
