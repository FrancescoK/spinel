# An exception subclass's marked message read emits the message handle,
# including when rescue specializes the receiver to the subclass for its ivars.
class MessageProblem < StandardError
  attr_reader :detail
  def initialize(text)
    super(text)
    @detail = 7
  end
end

def messages
  begin
    raise MessageProblem.new(+"invalid")
  rescue MessageProblem => e
    p e.detail
    [e.class.name, e.message, e.to_s]
  end
end

values = messages
values[1] << "!"
p values[0], values[1]

def builtin_message
  begin
    raise ArgumentError, +"builtin"
  rescue ArgumentError => e
    [e.message]
  end
end
text = builtin_message
text[0] << "#"
p text
