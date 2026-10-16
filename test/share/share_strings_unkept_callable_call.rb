# spinel: gc-stress
# A method that hands its parameter to a lambda's, a proc's or a Method's
# call, or to a block's, and answers the parameter too, answers a String the
# callee kept: the call's callee is not followed, so the argument is taken as
# kept. Each check keeps the answer in one name, changes the String the callee
# stored through another, and reads both (CRuby: the one String).
$g = nil
def store(x) = $g = x
STORE = ->(x) { $g = x }
CURRIED = ->(a, x) { $g = x }.curry
class Box
  attr_reader :a
  def put(a) = @a = a
end

def via_lambda(s)
  l = ->(x) { store(x) }
  l.call(s)
  s
end
def via_dot(s)
  l = ->(x) { store(x) }
  l.(s)
  s
end
def via_aref(s)
  l = ->(x) { store(x) }
  l[s]
  s
end
def via_proc(s)
  STORE.yield(s)
  s
end
def via_eqq(s)
  STORE === s
  s
end
def via_method(s)
  method(:store).call(s)
  s
end
def via_method_aref(s)
  method(:store)[s]
  s
end
def via_block(s, &b)
  b.call(s)
  s
end
def via_param(f, s)
  f.call(s)
  s
end
def via_curry(s)
  CURRIED.(1).(s)
  s
end
def via_compose(s)
  (STORE >> ->(y) { y }).call(s)
  s
end
# a lambda that stores its argument and answers something else
def via_false(s)
  l = ->(x) { $g = x; false }
  l.call(s)
  s
end
FALSE_STORE = ->(x) { $g = x; false }
def via_const_false(s)
  FALSE_STORE.call(s)
  s
end
def via_const_eqq(s)
  FALSE_STORE === s
  s
end
def via_exec(s)
  instance_exec(s) { |x| $g = x }
  s
end
def via_size(s)
  l = ->(x) { x.size }
  l.call(s)
  s
end

def finish(label, b)
  $g << "!"
  p [label, b.a, b.a.equal?($g)]
end
b = Box.new; b.put(via_lambda(+"a")); finish("lambda", b)
b = Box.new; b.put(via_dot(+"b")); finish("dot", b)
b = Box.new; b.put(via_aref(+"c")); finish("aref", b)
b = Box.new; b.put(via_proc(+"d")); finish("yield", b)
b = Box.new; b.put(via_eqq(+"e")); finish("eqq", b)
b = Box.new; b.put(via_method(+"f")); finish("method", b)
b = Box.new; b.put(via_method_aref(+"g")); finish("method aref", b)
b = Box.new; b.put(via_block(+"h") { |x| $g = x }); finish("block", b)
b = Box.new; b.put(via_param(->(x) { $g = x }, +"i")); finish("param", b)
b = Box.new; b.put(via_curry(+"j")); finish("curry", b)
b = Box.new; b.put(via_compose(+"k")); finish("compose", b)
b = Box.new; b.put(via_false(+"n")); finish("false", b)
b = Box.new; b.put(via_const_false(+"p")); finish("const false", b)
b = Box.new; b.put(via_const_eqq(+"q")); finish("const eqq", b)
b = Box.new; b.put(via_exec(+"r")); finish("exec", b)
# the callee keeps nothing: the answer and the other String are two
$g = +"o"
b = Box.new; b.put(via_size(+"l")); finish("size", b)
$g = +"o"
b = Box.new; b.put(via_block(+"m") { |x| x.size }); finish("block, no store", b)
