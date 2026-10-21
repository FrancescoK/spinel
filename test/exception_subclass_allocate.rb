# Class#allocate on an exception subclass builds the exception without
# running initialize; its message defaults to the class name.
class Err < StandardError
  attr_reader :payload
  def initialize(value)
    $initialized += 1
    @payload = value
    super("initialized")
  end
end
$initialized = 0
e = Err.allocate
p [e.class, e.message, e.backtrace, e.cause, e.payload, $initialized]
f = [Err, 0][0].allocate
p [f.class, f.message, f.backtrace, f.cause, f.payload, $initialized]
begin
  raise e
rescue Err => caught
  p [caught.equal?(e), caught.message, caught.payload]
end
begin
  raise f
rescue Err => caught
  p [caught.equal?(f), caught.message, caught.payload]
end

class Plain < StandardError; end
k = Plain
p k.allocate.class
p Plain.allocate.message

class SysErr < SystemCallError; end
s = [SysErr, 0][0].allocate
p [s.class, s.message, s.errno]
