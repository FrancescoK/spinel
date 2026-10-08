# An uncalled runtime-name send does not expose the live methods' Strings.
# A reachable method and a container still return the original mutable object.
def unused_send(receiver, name, value)
  receiver.send(name, value)
end
def unused_public_send(receiver, name, value)
  receiver.public_send(name, value)
end
def unused_dunder_send(receiver, name, value)
  receiver.__send__(name, value)
end
def labelled(text)
  "[#{text}]"
end
class Message
  attr_reader :text
  def initialize(text) = @text = text
end
puts labelled("read")
message = Message.new(+"before")
message.text.replace("after")
p message.text
s = +"live"
items = [s]
items[0] << "!"
p s
