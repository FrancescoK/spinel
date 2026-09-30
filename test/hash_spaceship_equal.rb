# Hash#<=> is the generic <=>: 0 for the same object or an equal one, nil
# otherwise.
h = {a: 1}
g = {a: 1}
k = {a: 2}
p [h <=> h, h <=> g, h <=> k, h <=> 1, h <=> nil, h <=> "x", h <=> [1]]
sh = {"a" => 1}
sg = {"a" => 1}
p [sh <=> sh, sh <=> sg, sh <=> {"a" => 2}]
ih = {1 => 1}
p [ih <=> ih, ih <=> {1 => 1}, ih <=> {1 => 2}]
mh = {a: 1, "b" => 2}
p [mh <=> mh, mh <=> {a: 1, "b" => 2}, mh <=> {a: 1}]
eh = {}
p [eh <=> eh, eh <=> {}, eh <=> h]
ssv = {"a" => "x"}
p [ssv <=> ssv, ssv <=> {"a" => "x"}, ssv <=> {"a" => "y"}]
isv = {1 => "x"}
p [isv <=> isv, isv <=> {1 => "x"}, isv <=> {1 => "y"}]
class Plain; end
p [h <=> (1..2), h <=> Object.new, h <=> Plain.new]
$n = 0
def tick = ($n += 1; {a: 1})
p [tick <=> h, h <=> tick, $n]
x = [{a: 1}, 0][0]
p [x <=> x, x <=> h, x <=> k]
def cmp(a, b) = a <=> b
p [cmp(h, g), cmp(h, k), cmp(1, 2), cmp("a", "b")]
p [h.eql?(g), h == g]
