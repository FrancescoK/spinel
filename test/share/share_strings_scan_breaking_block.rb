# A scan block that leaves only through `break` never hands control back to
# the scan, so CRuby never checks its subject for a change: whatever names
# the subject has, the block's changes cannot be seen by the scan, and the
# match it keeps is a String of its own.

# the scan's value is kept in a local the block changes (`x` is the match of
# the turn before, never the subject while the block runs)
s = +"ab"
x = nil
2.times do
  x = s.scan(/./) { |m| x << "!" if x; break m }
end
x << "?"
p x, s

s1 = +"ab"
x1 = nil
3.times do
  x1 = s1.scan(/./) { |m| x1 << "!" if x1; break m }
end
x1 << "?"
p x1, s1

# the block changes the subject, then breaks
s2 = +"abc"
x2 = s2.scan(/./) { |m| s2 << "z"; m << "!"; break m }
p x2, s2

# a boxed subject with another name
t3 = +"abc"
s3 = [t3, 1].first
k3 = s3.scan(/b/) { |m| m << "!"; break m }
k3 << "?"
t3 << "d"
p k3, s3, t3

# an instance variable subject
class ScanIvar
  def initialize; @s = +"abc"; end
  def run = @s.scan(/./) { |m| @s << "z"; m << "!"; break m }
  attr_reader :s
end
o = ScanIvar.new
p o.run, o.s

# a `next` inside a nested loop belongs to the loop
s4 = +"abc"
x4 = s4.scan(/./) { |m| i = 0; while i < 2; i += 1; next; end; s4 << "z"; m << "!"; break m }
p x4, s4

# no match: the scan answers its subject, and a later change through x is
# a change of s
s5 = +""
x5 = nil
2.times do
  x5 = s5.scan(/./) { |m| x5 << "!" if x5; break m }
end
x5 << "?"
p x5, s5

s6 = +""
x6 = nil
2.times do
  x6 = s6.scan(/./) { |m| x6 << "!" if x6; break m }
  s6 << "a"
end
x6 << "?"
p x6, s6

# a parameter subject the block changes before it breaks
def scan_param_break(s)
  s.scan(/./) { |m| s << "z"; m << "!"; break m }
end
a7 = +"abc"
p scan_param_break(a7), a7
