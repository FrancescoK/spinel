def new_exception(klass, msg, bt)
  ne = klass.new msg
  ne.set_backtrace bt
  ne
end
begin
  raise ArgumentError, "boom"
rescue => e
  n = new_exception(e.class, e.message.dup, ["a:1", "b:2"])
  p [n.class, n.message, n.backtrace]
  n2 = new_exception(RuntimeError, "x", ["c:3"])
  p [n2.class, n2.message, n2.backtrace]
end
