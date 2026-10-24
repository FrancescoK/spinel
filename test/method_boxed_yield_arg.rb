class Msg
  attr_reader :id
  def initialize(id) = @id = id
end

class Relation
  def initialize(rows) = @rows = rows
  def map
    @rows.map { |x| yield x }
  end
end

def inbox(message) = { id: message.id, box: "inbox" }
def sent(message) = { id: message.id, box: "sent" }

def index(box, messages)
  serializer = box == "inbox" ? method(:inbox) : method(:sent)
  messages.map { |message| serializer.call(message) }
end

p index("inbox", Relation.new([Msg.new(1)]))
p index("sent", Relation.new([Msg.new(2)]))
p Relation.new([5, 6]).map { |n| n * 2 }
