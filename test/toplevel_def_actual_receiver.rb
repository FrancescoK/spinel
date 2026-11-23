def received(default = self)
  [self.class.name, default.class.name]
end
alias previous_received received

def label_from_receiver = label
def label = "root"
def receiver_note = @note
def receiver_closure = -> { self.class.name }
def public_identity = self.class.name
public :public_identity

class Receiver
  def initialize
    @note = 7
  end

  def label = "override"
  def via_instance = received
  def public_identity = "child/" + super
end

@note = :main
p received, Receiver.new.via_instance, :tag.__send__(:previous_received)
p Receiver.new.__send__(:label_from_receiver), label_from_receiver
p receiver_note, Receiver.new.__send__(:receiver_note)
p :tag.__send__(:receiver_closure).call
p Receiver.new.public_identity, :tag.public_identity

def assign_to_receiver(note)
  for @last in [note]
  end
  (@first, @second), @third = [[@last, 2], 3]
  [@first, @second, @third]
end

box = Receiver.new
p assign_to_receiver(:main), box.__send__(:assign_to_receiver, :box)
p @last, box.instance_variable_get(:@last)

def receiver_identity = self.class.name
def later_identity = -> { receiver_identity }
def yield_identity(prefix) = yield(prefix, self.class.name)
public :yield_identity

p box.__send__(:later_identity).call
p :symbol.yield_identity(:at) { |prefix, name| [prefix, name] }
