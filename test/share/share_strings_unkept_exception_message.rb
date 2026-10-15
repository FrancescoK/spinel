# spinel: gc-stress
# An exception keeps the String it is built with as its message. A method
# that gives its parameter to an exception it keeps, and answers the
# parameter too, answers a String the exception holds: the message is not a
# flow into a slot the walk names, so the parameter is taken as kept from
# the exception's arguments. Each check keeps the answer in one name,
# changes the message through the exception, and reads both (CRuby: the one
# String).
class Err < StandardError; end
class Wrapped < StandardError
  def initialize(m) = super(m)
end
$e = nil
class Box
  attr_reader :a
  def put(a) = @a = a
end
def built(s)
  $e = Err.new(s)
  s
end
def builtin(s)
  $e = RuntimeError.new(s)
  s
end
def key_error(s)
  $e = KeyError.new(s)
  s
end
def super_message(s)
  $e = Wrapped.new(s)
  s
end
def raised_class(s)
  begin
    raise Err, s
  rescue Err => e
    $e = e
  end
  s
end
def raised_new(s)
  begin
    raise Err.new(s)
  rescue Err => e
    $e = e
  end
  s
end
def raised_string(s)
  begin
    raise s
  rescue => e
    $e = e
  end
  s
end
# the exception only names the String's size: nothing keeps it
def sized(s)
  $e = Err.new(s.size.to_s)
  s
end
def finish(b)
  $e.message << "!"
  p [b.a, b.a.equal?($e.message)]
end
b = Box.new; b.put(built(+"a")); finish(b)
b = Box.new; b.put(builtin(+"b")); finish(b)
b = Box.new; b.put(key_error(+"c")); finish(b)
b = Box.new; b.put(super_message(+"d")); finish(b)
b = Box.new; b.put(raised_class(+"e")); finish(b)
b = Box.new; b.put(raised_new(+"f")); finish(b)
b = Box.new; b.put(raised_string(+"g")); finish(b)
r = sized(+"h"); $e.message << "?"; p [r, $e.message]
