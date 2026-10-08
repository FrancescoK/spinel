# Shared String storage still selects and binds a reopening's block method.
# Assignment receivers retain the storage type that ordinary reads unwrap.
class String
  def handle_receiver_yield
    yield +"fresh", 7
    "done"
  end
  def handle_receiver_method
    yield +"method"
    "method done"
  end
  def handle_receiver_optional
    yield +"optional" if block_given?
    "optional done"
  end
  def handle_receiver_proc(&block)
    block.call(+"proc")
    "proc done"
  end
  def handle_receiver_read
    yield self
    self
  end
end

s = +"local"
other = s
s << "!"
p (s ||= +"unused").handle_receiver_yield { |text, n| p text.bytes, n }
p (s &&= other).handle_receiver_yield { |text, n| GC.start; p text, n }
p (s = other).handle_receiver_yield { |text, n| p text, n }
p other

# A Method block gets its String parameter from the resolved yield target.
def handle_receiver_consume(text)
  p text.bytes
end
p (s ||= +"unused").handle_receiver_method(&method(:handle_receiver_consume))
p (s ||= +"unused").handle_receiver_optional
p (s ||= +"unused").handle_receiver_optional { |text| p text }
p (s ||= +"unused").handle_receiver_proc { |text| GC.start; p text }
p s.handle_receiver_read { |text| GC.start; p text }

class HandleReceiverHolder
  def initialize
    @text = +"ivar"
  end
  def run
    @text << "!"
    p @text.handle_receiver_read { |text| p text }
    p (@text ||= +"unused").handle_receiver_read { |text| p text }
  end
end
HandleReceiverHolder.new.run

def handle_receiver_parameter(text)
  text << "!"
  p text.handle_receiver_read { |value| p value }
  p (text ||= +"unused").handle_receiver_yield { |value, n| p value, n }
end
handle_receiver_parameter(+"parameter")
