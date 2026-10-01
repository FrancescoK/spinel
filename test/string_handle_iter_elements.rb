# A String a block appends to through an iterator's parameter is the
# container's own element, as in CRuby: a Hash's value (each_value, each,
# each_pair, values.each), an ivar's Array, an Array literal the iterator
# hands back, an element a block names through a local it rebinds after,
# and a boxed element a guard narrows and hands to a method. Each was a
# copy of the element. So was the String `tap` hands a block.

X = "!"

h = {k: +"h"}; h.each_value { |x| x << X }; p h
g = {k: +"g"}; g.each { |k, x| x << X }; p g
f = {k: +"f"}; f.each_pair { |k, x| x << X }; p f
e = {k: +"e"}; e.values.each { |x| x << X }; p e

class K; def go(s) = (@a = [s]; @a.each { |w| w << X * 100 }; s.size); end
p K.new.go(+"a")
s = +"b"; @top = [s]; @top.each { |w| w << X }; p s

p([+"c"].each { |w| w << X })
p((+"d").tap { |w| w << X })

a = [+"r"]; a.each { |x| t = x; t << X; t = +"s" }; p a

def go(e) = e << X
m = [+"x", 1]; m.each { |el| go(el) if el.is_a?(String) }; p m
