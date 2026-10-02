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

# Target writes with no later observer still permit a copy.
thread_target = "lit"
thread_target, = [String.new("target")]
Thread.new(thread_target) { |q| q << "#"; puts q }.join

# Each method or lambda call starts with a fresh local.
def fresh_thread
  s = String.new("fresh")
  puts s
  Thread.new(s) { |q| q << "#"; puts q }.join
end
fresh_thread
fresh_thread
fresh_lambda_thread = -> {
  thread_lambda_local = String.new("lambda")
  puts thread_lambda_local
  Thread.new(thread_lambda_local) { |q| q << "#"; puts q }.join
}
fresh_lambda_thread.call
fresh_lambda_thread.call

# Discarded aliases and scalar query results keep no second name.
thread_discard = String.new("discard")
thread_discard.itself
p(thread_discard)
puts thread_discard.length
puts thread_discard.size
puts thread_discard.bytesize
p thread_discard.empty?
p thread_discard.frozen?
p puts(thread_discard)
p print(thread_discard)
Thread.new(thread_discard) { |q| q << "#"; puts q }.join
fiber_target = "lit"
fiber_target, = [String.new("target")]
Fiber.new { |q| q << "#"; puts q }.resume(fiber_target)

# Each method or lambda call starts with a fresh local.
def fresh_fiber
  s = String.new("fresh")
  puts s
  Fiber.new { |q| q << "#"; puts q }.resume(s)
end
fresh_fiber
fresh_fiber
fresh_lambda_fiber = -> {
  fiber_lambda_local = String.new("lambda")
  puts fiber_lambda_local
  Fiber.new { |q| q << "#"; puts q }.resume(fiber_lambda_local)
}
fresh_lambda_fiber.call
fresh_lambda_fiber.call

# Discarded aliases and scalar query results keep no second name.
fiber_discard = String.new("discard")
fiber_discard.itself
p(fiber_discard)
puts fiber_discard.length
puts fiber_discard.size
puts fiber_discard.bytesize
p fiber_discard.empty?
p fiber_discard.frozen?
p puts(fiber_discard)
p print(fiber_discard)
Fiber.new { |q| q << "#"; puts q }.resume(fiber_discard)

# This append receiver already shares its String.
fiber_shared_append = String.new("a")
fiber_shared_append_other = (fiber_shared_append << "")
Fiber.new { |q| q << "#" }.resume(fiber_shared_append)
puts fiber_shared_append_other

# This append receiver already shares its String.
fiber_shared_concat = String.new("a")
fiber_shared_concat_other = fiber_shared_concat.concat("")
Fiber.new { |q| q << "#" }.resume(fiber_shared_concat)
puts fiber_shared_concat_other

# This append receiver already shares its String.
thread_shared_append = String.new("a")
thread_shared_append_other = (thread_shared_append << "")
Thread.new(thread_shared_append) { |q| q << "#" }.join
puts thread_shared_append_other

# This append receiver already shares its String.
thread_shared_concat = String.new("a")
thread_shared_concat_other = thread_shared_concat.concat("")
Thread.new(thread_shared_concat) { |q| q << "#" }.join
puts thread_shared_concat_other
