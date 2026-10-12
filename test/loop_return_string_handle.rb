# A method whose body ends in a loop that never completes (`while true` or
# `until false` with no break of its own, `begin ... end while true`)
# answers through its `return`s alone. A String bang, a parameter or an
# instance or global variable returned from inside such a loop is the
# caller's String, in both builds.
def bang_while(a)
  while true
    return a.upcase!
  end
end

def bang_until(a)
  until false
    return a.capitalize!
  end
end

def param_do_while(a)
  begin
    return a
  end while true
end

def bang_through(b) = bang_while(b)

class Holder
  attr_reader :s

  def initialize
    @s = +"ivar"
  end

  def bang
    while true
      return @s.upcase!
    end
  end
end

$g = +"glob"
def global_bang
  until false
    return $g.upcase!
  end
end

s = +"ab"
r = bang_while(s)
p r
s2 = +"cd"
r2 = bang_while(s2)
r2 << "!"
p r2
s3 = +"ef"
r3 = bang_until(s3)
p s3, r3.equal?(s3)
s4 = +"gh"
r4 = param_do_while(s4)
r4 << "!"
p r4
s5 = +"AB"
p bang_while(s5)
s6 = +"ij"
r6 = bang_through(s6)
r6 << "?"
p s6, r6.equal?(s6)
h = Holder.new
r7 = h.bang
r7 << "!"
p h.s, r7.equal?(h.s)
r8 = global_bang
r8 << "!"
p $g, r8.equal?($g)
