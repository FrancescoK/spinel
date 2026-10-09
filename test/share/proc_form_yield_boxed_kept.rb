# spinel: gc-minor
# spinel: gc-stress
# A block a reopening's proc form yields a shared String to keeps the String
# itself, whatever it does to it afterwards.
class String
  def pm(a) = yield(a)
  def after(a)
    r = yield(a)
    a << ("x" * 300) if a.is_a?(String)
    r
  end
end
s = +"hello"
s << " world"
t = s
$h = {}
(+"ab").pm(s) { |v| $h[:a] = v; 0 }
s << ("y" * 400)
GC.start
p $h
p t.size
s = +"hello"
s << " world"
l = (+"ab").pm(s) { |v| -> { v + "!" } }
s.replace("q" * 500)
GC.start
p l.call.size
s = +"hello"
s << " world"
t = s
k = (+"ab").after(s) { |v| v }
GC.start
p k
p t.size
