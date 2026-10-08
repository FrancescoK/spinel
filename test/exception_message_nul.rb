# An exception message that holds a NUL keeps its bytes through every way of making
# and reading it (#7556). A message the runtime builds from a C buffer is still its
# strlen's. Tried with a GC at every allocation as well (make gc-stress-test).
# spinel: gc-stress
def show(e)
  p [e.class, e.message.bytes.size, e.message.bytes.count(0), e.to_s.bytes.size]
end
begin; raise ArgumentError, "before\0after"; rescue ArgumentError => e; show(e); end
begin; raise ArgumentError.new("before\0after"); rescue ArgumentError => e; show(e); end
begin; raise "plain\0str"; rescue => e; show(e); end
begin; raise StandardError, "\0leading"; rescue => e; show(e); end
begin; raise StandardError, "trailing\0"; rescue => e; show(e); end
begin; raise StandardError, "\0"; rescue => e; show(e); end
x = "n\0" + "x" * 40
begin; raise ArgumentError, "dyn #{x} #{x.size}"; rescue ArgumentError => e; show(e); end
e = ArgumentError.new("a\0b")
show(e)
class E2 < StandardError; end
begin; raise E2, "u\0v"; rescue E2 => e; show(e); end
begin; raise E2.new("u\0v"); rescue E2 => e; show(e); end
class E3 < StandardError; def initialize(m = "d") = super(m); end
begin; raise E3, "u\0v"; rescue E3 => e; show(e); end
# equality is by the bytes
p RuntimeError.new("q\0r") == RuntimeError.new("q\0r"), RuntimeError.new("q\0r") == RuntimeError.new("q")
p RuntimeError.new("q\0r").inspect.bytes.size, RuntimeError.new("q\0r").detailed_message.bytes.size
# a message without a NUL, or an empty one, is as before
begin; raise ArgumentError, ""; rescue ArgumentError => e; p e.message; end
begin; raise ArgumentError; rescue ArgumentError => e; p e.message; end
begin; raise ArgumentError, "plain"; rescue ArgumentError => e; p e.message; end
# it survives being re-raised and a GC between
begin
  begin; raise ArgumentError, "re\0raise"; rescue => e; GC.start; raise; end
rescue => e2
  show(e2)
end
# and a rescue that reads it after an ensure
begin
  begin; raise ArgumentError, "ens\0ure"; ensure; GC.start; end
rescue => e3
  show(e3)
end
