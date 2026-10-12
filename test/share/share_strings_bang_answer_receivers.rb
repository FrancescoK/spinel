# Under --share-strings a bang method's answer handed to a method
# (`show(b.upcase!)`) or answered by one (`def m(b) = b.upcase!`) is the
# receiver's String, or nil when the bang changed nothing, for a receiver
# that is a local, an instance variable, an Array element, a global or a
# call's value.
$n = 0
def id(x) = ($n += 1; x)
def show(x) = (x << "!" if x.is_a?(String); p(x))
def t_local(b) = b.upcase!
def t_none(b) = b.strip!
def t_elem(arr) = arr[0].sub!("a", "Q")
def t_elem_none(arr) = arr[id(0)].sub!("x", "Q")
def t_glob = $g.downcase!
def t_call(b) = id(id(b)).squeeze!
b = +"aab"; arr = [b]; @s = b; $g = b
show(b.upcase!)
show(b.upcase!)
show(@s.downcase!)
show(@s.sub!("x", "Q"))
show(arr[0].sub!("a", "Q"))
show(arr[id(0)].strip!)
show($g.capitalize!)
show(id(id(b)).swapcase!)
p b, $n
c = +"aab"; arr = [c]; $g = c
[t_local(c), t_none(c), t_elem(arr), t_elem_none(arr), t_glob, t_call(c)].each do |v|
  v << "?" if v
  p [v, c, v.equal?(c)]
end
p $n
