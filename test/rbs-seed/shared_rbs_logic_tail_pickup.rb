# Under --share-strings (#6765), a method an --rbs signature declares
# `-> String` whose tail is a boxed `||` or `&&` with an operand that is a
# call answering a shared String (`v || s`, `s || v`, `(v or s)`, `v && s`,
# `k || s` over a local) answers that String itself: the operand is boxed
# from the handle its call publishes, as an unseeded method's tail boxes it,
# not from its bytes, which held no handle and gave the caller a copy. The
# tail was refused for that reason; a caller that changes the buffer after
# the call sees the change through the answer (CRuby 4.0: the same object).
# An operand that answers a new String is boxed as a new handle. An operand
# nested in another `||` or `&&` or in a conditional (`(s || t) || v`,
# `(s && @t) || v`, `(v ? s : t) || v`) keeps the handle it answers, and so
# does a left operand that is an ivar or a local whose slot holds the handle
# (`@t || v`, `x = t; x || ident(v)`). So does a builtin call answering its
# receiver (`@s.itself`, `@s.then { |x| x }`, `@s.tap { }`, a bang, `@s << x`),
# also as an arm of a conditional, a `case` or a `begin` operand, beside the
# calls that publish nothing (an element read, `fetch`): the chain was
# refused for a builtin, and a conditional's arm was not looked at.
module LtConf
  class << self
    attr_accessor :key
  end
end

class LtApp
  def initialize(s)
    @s = s
  end

  def s = @s

  def fresh = @s.upcase

  def or_right(v)
    v || s
  end

  def or_left(v)
    s || v
  end

  def or_paren(v)
    (v or s)
  end

  def and_right(v)
    v && s
  end

  def or_local
    k = LtConf.key
    k || s
  end

  def or_fresh(v)
    v || fresh
  end
end

def pass(x) = x

def check(label, buf, y)
  buf << "!"
  p [label, y, y.equal?(buf)]
end

b = +"ab"
b << "c"
a = LtApp.new(b)
check(:or_right, b, pass(a.or_right(nil)))

b = +"ab"
b << "c"
a = LtApp.new(b)
check(:or_left, b, pass(a.or_left(nil)))

b = +"ab"
b << "c"
a = LtApp.new(b)
check(:or_paren, b, pass(a.or_paren(nil)))

b = +"ab"
b << "c"
a = LtApp.new(b)
check(:and_right, b, pass(a.and_right(1)))

b = +"ab"
b << "c"
a = LtApp.new(b)
LtConf.key = nil
check(:or_local, b, pass(a.or_local))

# the other operand wins: its own String, not the buffer
b = +"ab"
b << "c"
a = LtApp.new(b)
other = +"zz"
y = pass(a.or_right(other))
other << "!"
p [y, y.equal?(other), y.equal?(b)]
y = pass(a.or_left(other))
b << "?"
p [y, y.equal?(b)]
LtConf.key = other
y = pass(a.or_local)
other << "#"
p [y, y.equal?(other)]

# a new String answered by the call is a new String
b = +"ab"
b << "c"
a = LtApp.new(b)
y = pass(a.or_fresh(nil))
b << "!"
p [y, y.equal?(b)]

class LtApp2
  def initialize(s, t)
    @s = s
    @t = t
  end

  def s = @s
  def t = @t
  def falsev = false
  def ident(x) = x

  def nest_left(v)
    (s || t) || v
  end

  def nest_and(v)
    (s && @t) || v
  end

  def nest_or3
    (s or @t or falsev)
  end

  def nest_swap(v)
    (v && s) || t
  end

  def nest_cond(v)
    (v ? s : t) || v
  end

  def ivar_left(v)
    @t || v
  end

  def local_left(v)
    x = t
    x || ident(v)
  end
end

def check2(label, a, b, o, y)
  a << "!"
  b << "@"
  o << "#"
  p [label, y, y.equal?(a), y.equal?(b), y.equal?(o)]
end

def run2(label)
  a = +"ab"
  a << "c"
  b = +"pq"
  b << "r"
  o = +"oo"
  o << "p"
  y = yield LtApp2.new(a, b)
  check2(label, a, b, o, y)
end

run2(:nest_left) { |app| pass(app.nest_left(nil)) }
run2(:nest_and) { |app| pass(app.nest_and(nil)) }
run2(:nest_or3) { |app| pass(app.nest_or3) }
run2(:nest_swap) { |app| pass(app.nest_swap(1)) }
run2(:nest_cond) { |app| pass(app.nest_cond(nil)) }
run2(:ivar_left) { |app| pass(app.ivar_left(nil)) }
run2(:local_left) { |app| pass(app.local_left(nil)) }

run2(:nest_cond_s) { |app| pass(app.nest_cond(true)) }

class LtApp3
  def initialize(s, t)
    @s = s
    @t = t
    @arr = [s]
    @h = { "k" => s }
  end

  def s = @s
  def t = @t

  def b_itself(v) = @s.itself || v
  def b_then(v) = @s.then { |x| x } || v
  def b_tap(v) = @s.tap {} || v
  def b_bang(v) = @s.upcase! || v
  def b_append(v) = (@s << "") || v
  def b_and(v) = v && @s.itself
  def c_cond(v) = (v ? @s.itself : @t) || v
  def c_cond_tap(v) = (v ? @s.tap {} : @t) || v
  def c_case(v) = (case v when 1 then @s.itself else @t end) || v
  def c_begin(v) = (begin; @s.itself; end) || v
  def c_elem(v) = (v ? @arr[0] : @t) || v
  def c_hash(v) = (v ? @h["k"] : @t) || v
  def c_fetch(v) = (v ? @arr.fetch(0) : @t) || v
  def c_user(v) = (v ? s : t) || v
end

def run3(label)
  a = +"ab"
  a << "c"
  b = +"pq"
  b << "r"
  y = yield LtApp3.new(a, b)
  a << "!"
  b << "@"
  p [label, y, y.equal?(a), y.equal?(b)]
end

run3(:b_itself) { |app| pass(app.b_itself(nil)) }
run3(:b_then) { |app| pass(app.b_then(nil)) }
run3(:b_tap) { |app| pass(app.b_tap(nil)) }
run3(:b_bang) { |app| pass(app.b_bang(nil)) }
run3(:b_append) { |app| pass(app.b_append(nil)) }
run3(:b_and) { |app| pass(app.b_and(1)) }
run3(:c_cond) { |app| pass(app.c_cond(true)) }
run3(:c_cond_other) { |app| pass(app.c_cond(nil)) }
run3(:c_cond_tap) { |app| pass(app.c_cond_tap(true)) }
run3(:c_case) { |app| pass(app.c_case(1)) }
run3(:c_begin) { |app| pass(app.c_begin(nil)) }
run3(:c_elem) { |app| pass(app.c_elem(true)) }
run3(:c_hash) { |app| pass(app.c_hash(true)) }
run3(:c_fetch) { |app| pass(app.c_fetch(true)) }
run3(:c_user) { |app| pass(app.c_user(true)) }
