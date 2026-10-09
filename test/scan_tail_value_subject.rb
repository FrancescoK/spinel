# String#scan with a block answers its subject. At the tail of a method, lambda
# or proc over a literal, constant or call subject, in a block spliced into a
# yielding method, and on a boxed subject, the statement form ended the loop and
# the body answered nil (or did not build). A subject that is a plain local,
# instance variable or self was already put back; those cases are here to keep
# it so. Frozen literals answer the same object on every call.
def lit = "cd".scan(/./) { |m| m }
p lit
p [lit.class, lit.equal?(lit)]

l = -> { "ab".scan(/./) { |m| m } }
p l.call
p [l.call.class, l.call.equal?(l.call)]

pr = proc { "ef".scan(/./) { |m| m } }
p pr.call

SUBJ = "ghi"
def const_subject = SUBJ.scan(/./) { |m| m }
p const_subject
p const_subject.equal?(SUBJ)

class Holder
  def initialize
    @s = +"jk"
  end

  def ivar_subject = @s.scan(/./) { |m| m }

  def same? = ivar_subject.equal?(@s)

  def call_subject = make.scan(/./) { |m| m }

  def make = +"lm"
end
h = Holder.new
p h.ivar_subject
p h.same?
p h.call_subject

def string_pattern = "a.b.c".scan(".") { |m| m }
p string_pattern

def group_pattern = "a1b2".scan(/([a-z])(\d)/) { |c, d| c }
p group_pattern

def block_effects
  seen = []
  r = "xyz".scan(/./) { |m| seen << m.upcase }
  [r, seen]
end
p block_effects

def last_match_body = "a1".scan(/\d/) { |m| $~[0] }
p last_match_body

def in_branch(flag)
  if flag
    "on".scan(/./) { |m| m }
  else
    "off".scan(/./) { |m| m }
  end
end
p in_branch(true)
p in_branch(false)

def after_effect
  n = 0
  "abc".scan(/./) { n += 1 }
end
p after_effect

def var_subject(s) = s.scan(/./) { |m| m }
p var_subject("var")

def value_use = "uv".scan(/./) { |m| m }.upcase
p value_use

def mapped = [1, 2].map { "ab".scan(/./) { |m| m } }
p mapped

# a block spliced into a yielding method answers the subject too
def yy = yield
p(yy { "k9".scan(/\d/) { } })
yv = +"yv"
p(yy { yv.scan(/./) { } })
p(yy { SUBJ.scan(/./) { } }.equal?(SUBJ))

# a lambda and a proc over a constant and over a call result
lc = -> { SUBJ.scan(/./) { |m| m } }
p [lc.call, lc.call.equal?(SUBJ)]
pc = proc { make_subject.scan(/./) { |m| m } }
def make_subject = +"pc"
p pc.call

# a subject only known as a boxed value (a block parameter fed a String and an
# Integer) answers the String it walked
def wrap2(x) = yield(x)
p wrap2("cd cd") { |s| s.scan(/c/) { } }
p wrap2(3) { |n| n }
