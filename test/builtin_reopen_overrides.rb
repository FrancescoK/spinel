# A program's own reopen of a builtin primitive owns the name, as it does in
# CRuby: `class Integer; def abs; 999; end; end` makes `(-5).abs` answer 999.
# The reopened method was emitted and, for a name the compiler has no arm of
# its own for, called -- but an OVERRIDE of a real builtin method was
# silently ignored for a concrete receiver, because the dispatch that calls
# it sat after every builtin arm. Only a receiver typed at run time honoured
# a reopen.
class Integer
  def abs = 999
  def times = "no loop"
  def +(o) = 42
  def to_s(base = 10) = "INT"
  def succ = 77
  def shout = "int!"
end

class String
  def upcase = "nope"
  def to_s = "STR"
  def shout = "str!"
end

class Float
  def round(n = 0) = 3.5
end

p((-5).abs)
p 5.times
p(5 + 3)
p 5.to_s
p 5.succ
p 5.shout
p "ab".upcase
p "ab".to_s
p "ab".shout
p 1.234.round(1)

# A receiver typed only at run time takes the same answer. The poly arms
# that answer a name themselves (succ on an Integer tag, upcase on a String
# tag) stand down where a reopen owns it, and the dispatch's own arm runs.
def pick(v) = v
p pick(-5).abs
p pick(5).succ
p pick(1.234).round(1)
p pick("ab").upcase
p pick("ab").to_s
p pick(5).to_s

# Interpolation is to_s, so a reopened to_s owns it -- except for a String
# part, which CRuby uses as it stands (its objtostring never calls to_s on a
# String) even when String#to_s is reopened.
p "i=#{5}"
p "f=#{1.5}"
p "s=#{"ab"}"
p "n=#{-5}"

# A part that assigns converts its value the same way and still assigns: the
# conversion used to read the variable back under the call's name, `to_s`,
# and the C did not compile.
p "w=#{w = 7}"
p w

# and a name no reopen defines still answers the builtin at run time
p pick("ab").downcase
p pick(5).zero?
p pick("ab").reverse

# the builtin still answers a name the reopen does not define
p((-5).magnitude)
p "ab".downcase
p 5.zero?
