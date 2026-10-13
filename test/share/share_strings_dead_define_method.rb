# A runtime-name send inside the body of a define_method whose name is no
# literal does not expose the live methods' Strings: such a define_method is
# replaced by its NameError, so the body never runs -- here also in a class
# macro nothing calls. A reachable method and a container still return the
# original mutable object.
class Model
  def self.store_accessor(*keys)
    keys.each do |key|
      define_method(key) { public_send("#{key}_value") }
      define_method("#{key}=") { |value| send("write_#{key}", value) }
    end
  end
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
