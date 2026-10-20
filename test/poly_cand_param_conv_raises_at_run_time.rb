# A call on a receiver of no known class binds its arguments to every method
# of the name it may reach. Log#<< takes only Strings from its own callers,
# and the Entry pushed onto the Array in Thread.current reached its parameter
# that way, where `@buf << data` can only raise: the program was refused,
# though the receiver is an Array at run time. The raise is left to run time,
# where CRuby raises it when the receiver is a Log after all.

class Log
  def initialize
    @buf = +""
  end

  def update(data)
    @buf << data
    self
  end
  alias << update

  def text = @buf
end

class Entry
  def initialize(x)
    @x = x
  end
end

def entries(key)
  r = Thread.current[key]
  if r.nil?
    r = [Entry.new(0)]
    r.clear
    Thread.current[key] = r
  end
  r
end

Thread.current[:other] = Object.const_get(ARGV[0] || "Entry").allocate
entries(:a) << Entry.new(1)
entries(:a) << Entry.new(2)
p entries(:a).size

Thread.current[:log] = Log.new
begin
  Thread.current[:log] << Entry.new(3)
rescue TypeError => e
  p [e.class, e.message]
end
