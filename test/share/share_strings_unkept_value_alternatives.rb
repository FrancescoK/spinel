# spinel: gc-stress
# A value that is one of several (a Hash's or an Array's fetch default, the
# arm of a conditional or of `||`, a case) answers the String of whichever
# was taken. A method that stores such a value and answers its parameter
# too answers a String that is kept, whichever alternative the parameter is.
# Each check keeps the answer in one name, changes the stored String through
# another, and reads both (CRuby: the one String).
$g = nil
H = {a: 1}
A = [1]
class Box
  attr_reader :a
  def put(a) = @a = a
end
def fetch_default(s)
  $g = H.fetch(:q, s)
  s
end
def fetch_literal(s)
  $g = {}.fetch(:q, s)
  s
end
def fetch_array(s)
  $g = A.fetch(9, s)
  s
end
def fetch_in_local(s)
  x = H.fetch(:q, s)
  $g = x
  s
end
def fetch_block(s)
  $g = H.fetch(:q) { |k| s }
  s
end
def fetch_or(s)
  $g = H[:q] || s
  s
end
def second_arm(s, t)
  $g = (t.empty? ? t : s)
  s
end
def second_or(s, t)
  $g = (t || s)
  s
end
def case_arm(s, n)
  $g = case n when 1 then +"x" else s end
  s
end
def ivar_arm(s, t)
  @z = (t.empty? ? t : s)
  $g = @z
  s
end
# a break's value is one of the alternatives of the loop's
def break_loop(s)
  $g = loop { break s }
  s
end
def break_while(s)
  $g = while true
    break s
  end
  s
end
def break_each(s)
  $g = [1, 2].each { |i| break s if i == 2 }
  s
end
# a stored fetch of a key that is there answers the Hash's own value
def fetch_hit(s)
  h = {q: +"v"}
  $g = h.fetch(:q, s)
  s
end
def finish(b, n = 1)
  $g << "!"
  p [b.a, b.a.equal?($g)]
end
b = Box.new; b.put(fetch_default(+"a")); finish(b)
b = Box.new; b.put(fetch_literal(+"b")); finish(b)
b = Box.new; b.put(fetch_array(+"c")); finish(b)
b = Box.new; b.put(fetch_in_local(+"d")); finish(b)
b = Box.new; b.put(fetch_block(+"e")); finish(b)
b = Box.new; b.put(fetch_or(+"f")); finish(b)
b = Box.new; b.put(second_arm(+"g", +"t")); finish(b)
b = Box.new; b.put(second_or(+"h", nil)); finish(b)
b = Box.new; b.put(case_arm(+"i", 2)); finish(b)
b = Box.new; b.put(ivar_arm(+"j", +"t")); finish(b)
b = Box.new; b.put(fetch_hit(+"k")); finish(b)
b = Box.new; b.put(break_loop(+"l")); finish(b)
b = Box.new; b.put(break_while(+"m")); finish(b)
b = Box.new; b.put(break_each(+"n")); finish(b)
