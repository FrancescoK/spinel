# An exception raised inside Kernel#loop reaches the rescue as the same
# object, with its own instance variables
class Refusal < StandardError
  attr_reader :status
  def initialize(status, message)
    super(message)
    @status = status
  end
end

def stmt
  loop { raise Refusal.new(400, "bad") }
rescue Refusal => e
  [e.status, e.message]
end

def value
  x = loop { raise Refusal.new(413, "big") }
  x
rescue Refusal => e
  [e.status, e.message]
end

def nested
  loop do
    [1].each { raise Refusal.new(431, "long") }
  end
rescue Refusal => e
  [e.status, e.message]
end

def stops
  e = [1, 2].each
  loop { e.next }
  :stopped
end

err = Refusal.new(500, "same")
def same(err) = loop { raise err }
begin
  same(err)
rescue Refusal => e
  p e.equal?(err)
end
p stmt, value, nested, stops
