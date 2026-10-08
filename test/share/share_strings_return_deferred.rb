# spinel: gc-minor
# A fresh explicit return clears a shared read before every ensure runs.
class DeferredString
  def initialize(x)
    @x = x
  end
  def direct(f)
    return @x + "d" if f
    @x
  ensure
    @n = 1
  end
  def nested(f)
    begin
      begin
        while f
          return "<#{@x}>"
        end
        @x
      ensure
        @a = @x.size
      end
    ensure
      @b = @x
    end
  end
  def rescued(f)
    begin
      raise "retry" if f
      @x
    rescue
      return @x + "r"
    ensure
      @n = 2
    end
  end
  def assigned(f)
    return (v = @x * 2) if f
    @x
  ensure
    @n = 3
  end
end
src = "s".dup
a = DeferredString.new(src)
r = a.direct(true)
r << "!"
n = a.nested(true)
n << "?"
v = a.rescued(true)
v << "%"
w = a.assigned(true)
w << "&"
p r, n, v, w, src
r = a.direct(false)
r << "d"
n = a.nested(false)
n << "n"
v = a.rescued(false)
v << "r"
w = a.assigned(false)
w << "a"
p r, n, v, w, src
