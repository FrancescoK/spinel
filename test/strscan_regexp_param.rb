# StringScanner#scan and its kin take a Regexp held in a parameter or a
# constant, as they take a literal: the pattern pointer is the same (#5360).
require "strscan"
RE_WS = /\s+/
class Sc
  def initialize(s) = @s = StringScanner.new(s)
  def scan(pattern) = @s.scan(pattern)
  def check(pattern) = @s.check(pattern)
  def scan_until(pattern) = @s.scan_until(pattern)
end
def f(pat) = StringScanner.new("abc").scan(pat)
p f(/ab/), f(/x/)
s = Sc.new("  ab, cd")
p s.check(RE_WS), s.scan(RE_WS), s.scan(/\w+/), s.scan_until(/d/)
class Other; def scan(x) = "other:#{x.source}"; end
def g(o, pat) = o.scan(pat)
p g(StringScanner.new("xyz"), /xy/), g(Other.new, /q/)
