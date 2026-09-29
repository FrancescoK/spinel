# A slot written nil and a Range or Time holds the nil: the by-value structs
# have no nil of their own, so the slot boxes.

class Span
  def initialize = @r = nil
  def set(x) = @r = x
  def report = p([@r.nil?, @r, @r.to_s, @r == nil])
  def sum = @r ? @r.sum : 0
end
s = Span.new
s.report
p s.sum
s.set(1..3)
s.report
p s.sum
s.set(nil)
s.report

class FSpan
  def set(x) = @r = x
  def report = p([@r.nil?, @r])
end
f = FSpan.new
f.report
f.set(1.0..2.5)
f.report

class SSpan
  def set(x) = @r = x
  def report = p([@r.nil?, @r ? @r.to_a : nil])
end
ss = SSpan.new
ss.report
ss.set("a".."c")
ss.report

class Stamp
  def set(x) = @t = x
  def report = p([@t.nil?, @t ? @t.year : nil])
end
st = Stamp.new
st.report
st.set(Time.at(0).utc)
st.report

$g = nil
def gr = p([$g.nil?, $g])
gr
$g = (2..4)
gr
p $g.to_a

x = [1, 2].first&.then { |v| v..3 }
p x
