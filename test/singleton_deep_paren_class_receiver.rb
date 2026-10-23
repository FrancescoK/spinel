# A singleton definition on self or a class keeps that receiver past eight
# parentheses, just as a shallow parenthesized receiver does. A constant
# receiver names its own class even when the def appears in another class.
class ParenClassReceiver
  def (self).shallow = 1
  def (((((((((self))))))))).deep = 9
end
def (ParenClassReceiver).constant_shallow = 2
def ((((((((((((((((ParenClassReceiver)))))))))))))))).outside = 16
class ParenReceiverHost
  def (((((((((ParenClassReceiver))))))))).from_other = 10
end
p ParenClassReceiver.shallow
p ParenClassReceiver.deep
p ParenClassReceiver.constant_shallow
p ParenClassReceiver.outside
p ParenClassReceiver.from_other
