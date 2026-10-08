# A Method created in a proc keeps the enclosing instance as its receiver.
# Returning a captured String preserves its identity and frozen state.
class CapturedMethod
  def identity(value) = value

  def run
    s = "aab#{ARGV.size}"
    f = lambda do
      t = method(:identity).call(s)
      p s.equal?(t), s.size, t.size
      s << "x"
      p s, t, s.equal?(t)
      t.upcase!
      p s, t, s.frozen?, t.frozen?
    end
    f.call

    frozen = "fixed"
    outer = proc do
      inner = lambda do
        bound = method(:identity)
        t = bound.call(frozen)
        p frozen.equal?(t), t.frozen?
        begin
          t << "!"
        rescue FrozenError => e
          p e.class
        end
        p frozen, t
      end
      inner.call
    end
    outer.call
  end
end
CapturedMethod.new.run
