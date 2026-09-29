# `private def m` / `protected def m` / `public def m` inside `class << self`
# define class methods, reached from the other class methods.
class E
  class << self
    private def pz = 1
    def ok = pz
  end
end
p E.ok

class D
  class << self
    protected def pz = 4
    public def ok = pz + 1
  end
end
p D.ok

class W
  class << self
    private def scale(x, by: 2) = x * by
    def run(v) = scale(v) + scale(v, by: 10)
  end
end
p W.run(3)

module M
  class << self
    private def helper(s) = s.upcase
    def shout(s) = "#{helper(s)}!"
  end
end
puts M.shout("hi")

class Y
  class << self
    if true
      private def inner = :yes
    end
    def outer = inner
  end
end
p Y.outer
