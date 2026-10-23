# A singleton def's receiver is the same object beyond eight parentheses.
# Keep shallow receivers and both user objects and Object instances beside it.
class ParenReceiver; end
shallow = ParenReceiver.new
boundary = ParenReceiver.new
deep = ParenReceiver.new
plain_object = Object.new
def (shallow).answer = 1
def ((((((((boundary)))))))).answer = 8
def (((((((((deep))))))))).answer = 9
def ((((((((((((((((plain_object)))))))))))))))).answer = 16
p shallow.answer
p boundary.answer
p deep.answer
p plain_object.answer
