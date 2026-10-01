# A variadic C function: the types end with TYPE_VARIADIC, and each variadic
# argument is passed as a (type, value) pair.
require "fiddle"

snprintf = Fiddle::Function.new(Fiddle::Handle::DEFAULT["snprintf"],
  [Fiddle::TYPE_VOIDP, Fiddle::TYPE_SIZE_T, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VARIADIC], Fiddle::TYPE_INT)
buf = Fiddle::Pointer.malloc(64)

n = snprintf.call(buf, 64, "%d-%s-%.1f", Fiddle::TYPE_INT, 42, Fiddle::TYPE_VOIDP, "x", Fiddle::TYPE_DOUBLE, 2.5)
p n, buf.to_s
n = snprintf.call(buf, 64, "plain")
p n, buf.to_s
n = snprintf.call(buf, 64, "%ld %u", Fiddle::TYPE_LONG, 5_000_000_000, Fiddle::TYPE_UINT, 7)
p n, buf.to_s

begin
  snprintf.call(buf, 64, "%d", Fiddle::TYPE_INT)
rescue ArgumentError => e
  puts "ArgumentError: #{e.message.split(":").first}"
end
begin
  snprintf.call(buf, 64)
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end
begin
  Fiddle::Function.new(Fiddle::Handle::DEFAULT["snprintf"], [Fiddle::TYPE_VARIADIC, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
rescue ArgumentError => e
  puts e.message.start_with?("Fiddle::TYPE_VARIADIC must be the last argument type")
end
