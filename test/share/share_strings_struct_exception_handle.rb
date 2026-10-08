# A shared Struct member keeps its handle through an exception value.
class StructExceptionHandle
  St = Struct.new(:value)

  def run
    o = St.new(+"aabc")
    t = begin
      raise o.value
    rescue => e
      e.message
    end
    puts o.value.frozen?.to_s + " " + t.frozen?.to_s
    begin
      t[0] = "Q"
      puts "ok"
    rescue => e
      puts e.class.to_s
    end
    puts o.value.frozen?.to_s + " " + t.frozen?.to_s
    p([o.value, t])
  end
end

StructExceptionHandle.new.run

# Reading an attribute from an effectful receiver runs once. A frozen
# message retains both its identity and its mutation error.
class MessageHolder
  attr_reader :value
  def initialize(value)
    @value = value
  end
  def receiver(log)
    log << :read
    self
  end
end
log = []
holder = MessageHolder.new("frozen")
begin
  raise holder.receiver(log).value
rescue => e
  p e.message.equal?(holder.value), e.message.frozen?
  begin
    e.message[0] = "Q"
  rescue FrozenError
    p :frozen
  end
end
p log
