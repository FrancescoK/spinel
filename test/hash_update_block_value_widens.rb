# update / merge! / merge store the conflict block's value under a
# colliding key, so a block answering another class than the hash's values
# widens the hash; merged pairs of another value type do the same.

class C
  def initialize = @w = {"a" => 1}
  def go
    @w.update("a" => 2) { |_k, o, n| "s#{o + n}" }
    p @w
    @w.merge!("b" => 3) { |_k, o, n| o + n }
    p @w
  end
end
C.new.go

h = {"a" => 1}
h.update("a" => 2) { |_k, o, n| :sym }
p h

g = {"a" => 1}
g.update("b" => "x")
p g

s = {a: 1, b: 2}
s.update(a: 3) { |_k, o, n| "#{o}-#{n}" }
p s

i = {1 => 10}
i.merge!(1 => 20, 2 => 30) { |_k, o, n| (o + n).to_s }
p i

f = {"x" => 1}
f.update("x" => 2) { |_k, o, n| (o + n) / 2.0 }
p f

q = {"x" => 1}
r = q.merge("x" => 2, "y" => 3) { |_k, o, n| [o, n] }
p r, q

m = {"a" => 1}
p m.merge("a" => 2) { |_k, o, n| "s#{o + n}" }
p m

class H
  def initialize; @h = {1 => "a"}; end
  def go
    @h.merge!(1 => "b") { |_k, o, n| (o + n).size }
    @h
  end
end
p H.new.go

$gh = {"k" => 1}
$gh.update("k" => 2) { |_k, o, n| nil }
p $gh

e = {"a" => 1}
e.update("a" => 2) { |_k, o, n| o + n }
p e
