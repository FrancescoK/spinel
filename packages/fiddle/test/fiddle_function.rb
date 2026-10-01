# Fiddle::Handle and Fiddle::Function: symbols looked up in the process, C
# functions called with every scalar type, the errors a bad call raises.
require "fiddle"

h = Fiddle::Handle::DEFAULT
p h.class, h.sym("abs").class, h.sym_defined?("abs").class, h.sym_defined?("no_such_symbol_zz")
p Fiddle::Handle.new(nil).class, Fiddle.dlopen(nil).class
begin
  h["no_such_symbol_zz"]
rescue Fiddle::DLError => e
  puts "DLError: #{e.message}"
end
begin
  Fiddle::Handle.new("no_such_library_zz")
rescue Fiddle::DLError
  puts "DLError on dlopen"
end
closed = Fiddle::Handle.new(nil)
closed.close
begin
  closed.sym("abs")
rescue Fiddle::DLError => e
  puts "DLError: #{e.message}"
end

def fn(name, args, ret) = Fiddle::Function.new(Fiddle::Handle::DEFAULT[name], args, ret)

p fn("cos", [Fiddle::TYPE_DOUBLE], Fiddle::TYPE_DOUBLE).call(0.0)
p fn("cos", [Fiddle::TYPE_DOUBLE], Fiddle::TYPE_DOUBLE).call(0)
p fn("sqrtf", [Fiddle::TYPE_FLOAT], Fiddle::TYPE_FLOAT).call(16.0)
p fn("abs", [Fiddle::TYPE_INT], Fiddle::TYPE_INT).call(-7)
p fn("abs", [Fiddle::TYPE_INT], Fiddle::TYPE_INT).call(-3.9)
p fn("labs", [Fiddle::TYPE_LONG], Fiddle::TYPE_LONG).call(-9)
p fn("llabs", [Fiddle::TYPE_LONG_LONG], Fiddle::TYPE_LONG_LONG).call(-5_000_000_000)
p fn("toupper", [Fiddle::TYPE_INT], Fiddle::TYPE_CHAR).call(97)
p fn("labs", [Fiddle::TYPE_LONG], -Fiddle::TYPE_LONG).call(-1)
p fn("abs", [-Fiddle::TYPE_INT], Fiddle::TYPE_INT).call(-3)
p fn("strlen", [Fiddle::TYPE_VOIDP], Fiddle::TYPE_SIZE_T).call("hello")
p fn("strlen", [Fiddle::TYPE_VOIDP], Fiddle::TYPE_SIZE_T).call(Fiddle::Pointer["hey"])
p fn("strlen", [Fiddle::TYPE_CONST_STRING], Fiddle::TYPE_SIZE_T).call("héllo")
p fn("strdup", [Fiddle::TYPE_CONST_STRING], Fiddle::TYPE_CONST_STRING).call("abc")
p fn("srand", [-Fiddle::TYPE_INT], Fiddle::TYPE_VOID).call(1)

r = fn("getenv", [Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOIDP).call("PATH")
p r.class, r.null?
p fn("getenv", [Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOIDP).call("NO_SUCH_VARIABLE_ZZ").null?

f = Fiddle::Function.new(Fiddle::Handle::DEFAULT["abs"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT, name: "abs")
p f.name, f.abi, f.ptr.class, f.to_i.class, f.to_proc.call(-4)
p Fiddle::Function.new(Fiddle::Pointer.new(Fiddle::Handle::DEFAULT["abs"]), [Fiddle::TYPE_INT], Fiddle::TYPE_INT).call(-5)

begin
  f.call(1, 2)
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end
begin
  f.call
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end
begin
  f.call("x")
rescue TypeError => e
  puts "TypeError: #{e.message}"
end
begin
  Fiddle::Function.new(Fiddle::Handle::DEFAULT["abs"], [99], Fiddle::TYPE_INT)
rescue => e
  puts "#{e.class}: #{e.message}"
end
begin
  Fiddle::Function.new(Fiddle::Handle::DEFAULT["abs"], Fiddle::TYPE_INT, Fiddle::TYPE_INT)
rescue TypeError => e
  puts "TypeError: #{e.message}"
end
Fiddle.last_error = 7
p Fiddle.last_error
