# A run-time __send__ fans the call out over every method of its arity, and
# Util.escape (whose parameter reaches an append through a reassigned name)
# makes the argument a shared String handle (sp_String *) for every arm. The
# arm for a native class method taking a String (IO::Buffer#set_string) passed
# that handle where the C function takes the String bytes (const char *), and
# the C did not compile. The arm now hands it the String the handle holds.
module Util
  module_function

  def append_x(str)
    str = str
    str << "x"
  end

  def escape(str)
    append_x(str)
  end
end

class Other
end

class Auth
  def initialize(target)
    @target = target
  end

  def log(meth, fmt)
    msg = format("%s: ", fmt)
    @target.__send__(meth, msg)
  end
end

buf = IO::Buffer.new(8)
a = Auth.new(buf)
b = Auth.new(Other.new)
p a.log(:set_string, "one")
p buf.get_string(0, 5)
p [buf.respond_to?(:escape), buf.respond_to?(:call)]
p Util.escape(+"ab")
begin
  b.log(:set_string, "two")
rescue NoMethodError
  p :no_set_string
end
