# A container's mark on a boxed reader still names its original shared field.
class Packet
  attr_reader :body
  alias content body
  def initialize(body)
    @body = body
  end
end
Envelope = Struct.new(:body)

packet = [Packet.new(+"data"), 1][0]
envelope = [Envelope.new(+"note"), 1][0]
values = [packet.body, envelope.body]
headers = {"body" => packet.content}
values[0] << "!" * 80
headers["body"] << "?"
values[1] << "#" * 80
p [packet.body.size, envelope.body.size]
p [packet.body.equal?(values[0]), packet.content.equal?(headers["body"])]
p envelope.body.equal?(values[1])

fixed = [Packet.new("fixed"), 1][0]
saved = [fixed.body]
begin
  saved[0] << "!"
rescue FrozenError
  p fixed.body
end
