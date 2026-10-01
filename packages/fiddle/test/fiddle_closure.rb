# Fiddle::Closure: Ruby code behind a C function pointer, called by C (qsort,
# bsearch) and from Ruby; BlockCaller and a subclass with its own #call.
require "fiddle"

libc = Fiddle::Handle::DEFAULT
qsort = Fiddle::Function.new(libc["qsort"],
  [Fiddle::TYPE_VOIDP, Fiddle::TYPE_SIZE_T, Fiddle::TYPE_SIZE_T, Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOID)

calls = 0
cmp = Fiddle::Closure::BlockCaller.new(Fiddle::TYPE_INT, [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP]) do |a, b|
  calls += 1
  Fiddle::Pointer.new(a)[0, 1].ord <=> Fiddle::Pointer.new(b)[0, 1].ord
end
p cmp.class, cmp.to_i.class, cmp.args, cmp.ctype, cmp.freed?

buf = Fiddle::Pointer.malloc(5)
buf[0, 5] = "dcbae"
qsort.call(buf, 5, 1, cmp)
p buf.to_s(5), calls > 0
buf[0, 5] = "zyxwv"
qsort.call(buf, 5, 1, cmp.to_i)
p buf.to_s(5)

# arguments of each type reach the block as Ruby values
seen = []
adder = Fiddle::Closure::BlockCaller.new(Fiddle::TYPE_DOUBLE, [Fiddle::TYPE_INT, Fiddle::TYPE_DOUBLE, Fiddle::TYPE_LONG]) do |i, d, l|
  seen << [i, d, l]
  i + d + l
end
p adder.call(1, 2.5, 3), seen

# called from C through the pointer: a function made over the closure's address
twice = Fiddle::Closure::BlockCaller.new(Fiddle::TYPE_INT, [Fiddle::TYPE_INT]) { |x| x * 2 }
f = Fiddle::Function.new(twice.to_i, [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
p f.call(21), f.call(-4)

# a subclass defines #call itself
class Negator < Fiddle::Closure
  def call(x) = -x
end
neg = Negator.new(Fiddle::TYPE_INT, [Fiddle::TYPE_INT])
p Fiddle::Function.new(neg.to_i, [Fiddle::TYPE_INT], Fiddle::TYPE_INT).call(9)

# a closure returning an address
mk = Fiddle::Closure::BlockCaller.new(Fiddle::TYPE_VOIDP, []) { buf }
r = Fiddle::Function.new(mk.to_i, [], Fiddle::TYPE_VOIDP).call
p r.class, r.to_i == buf.to_i

twice.free
p twice.freed?
begin
  Fiddle::Closure::BlockCaller.new(99, [Fiddle::TYPE_INT]) { }
rescue => e
  puts "#{e.class}: #{e.message}"
end
