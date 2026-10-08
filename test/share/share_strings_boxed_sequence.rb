s = +"a\0"
log = []
values = [(log << 1; s << (log << 2; "x" * 100))]
p [log, values[0].equal?(s), values[0].bytesize]
values[0] << "!"
p [s.bytesize, s.getbyte(1)]

# A snapshot inserted by the compiler must carry the old receiver too.
def rebind(s) = [s << (s = +"next"), s]
x = +"old"
a = rebind(x)
p [a, a[0].equal?(x)]
a[0] << "!"
p x

# A statement's effects precede the final value's setup, once per call.
def keep(first, second) = [first, second]
s = +"a"
a = keep((log << 3; s), (log << 4; s << "b"))
p [log, a[0].equal?(s), a[1].equal?(s)]

frozen = "frozen"
a = [(log << 5; frozen)]
begin
  a[0] << "!"
rescue FrozenError
  puts "still frozen"
end
p log
