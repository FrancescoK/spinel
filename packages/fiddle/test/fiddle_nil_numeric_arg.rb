# nil where a Fiddle function or closure wants a C integer or double is a
# TypeError, as CRuby's NUM2INT / NUM2DBL raise; it was passed as 0 / 0.0.
require "fiddle"

h = Fiddle::Handle::DEFAULT
abs = Fiddle::Function.new(h["abs"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
p abs.call(-3)
begin
  p abs.call(nil)
rescue TypeError => e
  puts "TypeError: #{e.message}"
end
fabs = Fiddle::Function.new(Fiddle.dlopen(nil)["fabs"], [Fiddle::TYPE_DOUBLE], Fiddle::TYPE_DOUBLE)
p fabs.call(-2.5)
begin
  p fabs.call(nil)
rescue TypeError => e
  puts "TypeError: #{e.message}"
end

# Fiddle keeps its strict closure conversion even though ffi zeroes nil.
[Fiddle::TYPE_CHAR, Fiddle::TYPE_SHORT, Fiddle::TYPE_INT, Fiddle::TYPE_LONG,
 Fiddle::TYPE_LONG_LONG, -Fiddle::TYPE_CHAR, -Fiddle::TYPE_SHORT,
 -Fiddle::TYPE_INT, -Fiddle::TYPE_LONG, -Fiddle::TYPE_LONG_LONG,
 Fiddle::TYPE_FLOAT, Fiddle::TYPE_DOUBLE, Fiddle::TYPE_VOIDP,
 Fiddle::TYPE_CONST_STRING, Fiddle::TYPE_BOOL, Fiddle::TYPE_VOID].each do |type|
  puts type
  closure = Fiddle::Closure::BlockCaller.new(type, []) { nil }
  function = Fiddle::Function.new(closure.to_i, [], type)
  begin
    p function.call
  rescue TypeError => e
    puts "TypeError: #{e.message}"
  end
end
