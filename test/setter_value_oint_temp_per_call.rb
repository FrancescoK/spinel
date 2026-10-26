# The value of `obj.x = v` through a writer method is v. A writer whose
# argument may be nil holds it in an oint temp; a later writer in another
# method, whose temp got the same number, unwrapped its plain Boolean as an
# oint and the C did not compile.
class Bus
  def lines=(n)
    @lines = n
    puts "lines #{n.inspect}"
  end

  def flag=(on)
    @flag = on
    puts "flag #{on}"
  end
end

def maybe(n) = n > 0 ? n : nil

def set_maybe(bus, n)
  bus.lines = maybe(n)
end

def set_flag(bus)
  x = bus.to_s.size
  bus.flag = x > 1000
end

bus = Bus.new
p set_maybe(bus, 3)
p set_maybe(bus, 0)
p set_flag(bus)
