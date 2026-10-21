# A String mutator called through `&.` as a statement changes the String
# its receiver holds, and does nothing for a nil receiver: `s&.slice!(1)`,
# `s&.insert(0, "x")`, `s&.[]=(0, "x")`, `s&.setbyte(0, 65)`, `s&.upcase!`
# and `s&.<<("x")` on a local (read again, and through another name that
# holds the same String), a parameter, an instance variable and a global,
# and on a call that answers its argument. The guard that tests the
# receiver for nil held a copy of a variable's String, so the change
# reached the copy; over a call, it read the copy the mutator works on
# before that copy was declared, and the C did not build.
def mk(b) = b ? +"abc" : nil
def id(x) = x

def local(b)
  s = mk(b); s&.slice!(1); a = s
  s = mk(b); s&.insert(0, "x"); i = s
  s = mk(b); s&.[]=(0, "x"); e = s
  s = mk(b); s&.setbyte(0, 65); y = s
  s = mk(b); s&.upcase!; u = s
  s = mk(b); s&.<<("x"); c = s
  p [a, i, e, y, u, c]
end

def alias_slice(b) = (s = mk(b); t = s; s&.slice!(1); t)
def alias_insert(b) = (s = mk(b); t = s; s&.insert(0, "x"); t)
def alias_aset(b) = (s = mk(b); t = s; s&.[]=(0, "x"); t)
def alias_setbyte(b) = (s = mk(b); t = s; s&.setbyte(0, 65); t)
def alias_upcase(b) = (s = mk(b); t = s; s&.upcase!; t)
def alias_append(b) = (s = mk(b); t = s; s&.<<("x"); t)

def aliased(b)
  p [alias_slice(b), alias_insert(b), alias_aset(b), alias_setbyte(b), alias_upcase(b), alias_append(b)]
end

def param_slice(s) = (s&.slice!(1); nil)
def param_insert(s) = (s&.insert(0, "x"); nil)
def param_append(s) = (s&.<<("x"); nil)

def param(b)
  s = mk(b); param_slice(s); a = s
  s = mk(b); param_insert(s); i = s
  s = mk(b); param_append(s); c = s
  p [a, i, c]
end

class Holder
  def initialize(b) = (@s = mk(b))
  def slice = (t = @s; @s&.slice!(1); t)
  def insert = (t = @s; @s&.insert(0, "x"); t)
  def append = (t = @s; @s&.<<("x"); t)
end

def ivar(b)
  p [Holder.new(b).slice, Holder.new(b).insert, Holder.new(b).append]
end

def global(b)
  $g = mk(b); t = $g; $g&.slice!(1); a = t
  $g = mk(b); t = $g; $g&.[]=(0, "x"); e = t
  p [a, e]
end

def call_slice = (s = mk(true); t = s; id(s)&.slice!(1); t)
def call_insert = (s = mk(true); t = s; id(s)&.insert(0, "x"); t)
def call_aset = (s = mk(true); t = s; id(s)&.[]=(0, "x"); t)
def call_setbyte(b) = (s = mk(b); t = s; id(s)&.setbyte(0, 65); t)
def call_upcase(b) = (s = mk(b); t = s; id(s)&.upcase!; t)
def call_append = (s = mk(true); t = s; id(s)&.<<("x"); t)

[true, false].each do |b|
  local(b)
  aliased(b)
  param(b)
  ivar(b)
  global(b)
end
p [call_slice, call_insert, call_aset, call_setbyte(true), call_upcase(true), call_append]
p [call_setbyte(false), call_upcase(false)]
