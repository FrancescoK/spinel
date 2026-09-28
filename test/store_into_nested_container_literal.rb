# A store through an element read into a container literal nested in another
y = {"a" => {"q" => 4}}
y["a"]["r"] = :s
p y

class T
  def initialize
    @cfg = {"a" => {"q" => 1}}
  end
  def set = @cfg["a"]["r"] = "x"
  attr_reader :cfg
end
t = T.new
t.set
p t.cfg

d = {"a" => {"b" => {"c" => 1}}}
d["a"]["b"]["d"] = :deep
p d

z = {"a" => {"q" => 4}}
z["a"]["r"] ||= :s
p z

h = {1 => {"q" => 4}}
h[1].store("r", "x")
p h

a = [[1]]
a[0] << "x"
p a

m = [[1, 2], [3]]
m.first.push("s")
m.last.unshift(:u)
p m

$g = [[1.5]]
$g[0].concat(["w"])
p $g

e = {"k" => {}}
e["k"][1] = "one"
e["k"]["two"] = 2
p e

f = [{"q" => 1}]
f[0]["r"] = :s
p f

# several values in one push, unshift or insert
m = [[1], [2]]
m[0].push(2, "x")
m[1].unshift(:s, 3)
n = [[1, 2]]
n[0].insert(1, 5, "y")
p m, n
