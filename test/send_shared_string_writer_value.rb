# `x.sync_close = v` reached through a run-time __send__ on a boxed receiver
# answers the value it stored. With the argument a shared String handle
# (Util.escape, one of the arms the __send__ fans out to, makes it one) the
# writer arm answered the handle (sp_String *) where the call is read as a
# String (const char *), and the C did not compile. The arm now answers the
# String the handle holds.
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

class Holder
  attr_accessor :sync_close
end

class Other
end

class Auth
  def initialize(logger)
    @logger = logger
  end

  def log(meth, fmt)
    msg = format("%s: ", fmt)
    @logger.__send__(meth, msg)
  end
end

h = Holder.new
a = Auth.new(h)
b = Auth.new(Other.new)
p [h.respond_to?(:escape), h.respond_to?(:call)]
p a.log(:sync_close=, "one")
p h.sync_close
p Util.escape(+"ab")
begin
  b.log(:sync_close=, "two")
rescue NoMethodError
  p :no_writer
end
