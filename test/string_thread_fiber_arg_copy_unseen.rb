# A String variable handed to a thread's or a fiber's block that appends to
# it goes over as a copy. Where nothing can tell -- the variable is never
# read again, or only before, to print it -- the program compiles and
# answers as CRuby does; where something can, it is refused
# (test/reject/string_thread_*).

s = +"ab"; p s; Thread.new(s) { |t| t.upcase!; p t }.join
f = +"f"; Fiber.new { |x| x << "!"; p x }.resume(f)
r = +"r"; Thread.new(r) { |t| p t.size }.join; p r
q = +"q"; [1].each { Thread.new(q) { |t| t << "z"; p t }.join }
$g = +"g"; Thread.new($g) { |t| t << "y"; p t }.join
def m(s) = Thread.new(s) { |t| t << "x"; p t }.join
w = +"w"; m(w); m(+"v")

# A read after replacing the variable does not observe the old String.
r2 = +"old"
Thread.new(r2) { |t| t << "!" }.join
r2 = +"new"
p r2
r3 = +"a"
r3 = Thread.new(r3) { |t| t << "!" }.value
p r3

# A second resume answers Fiber.yield; it does not bind the block again.
f2 = Fiber.new { |t| t << "!"; Fiber.yield; :done }
f2.resume(+"a")
u2 = +"b"
p f2.resume(u2)
p u2

# Printing a global before the call does not retain its String.
$before = +"before"
p $before
Thread.new($before) { |t| t << "!"; p t }.join
