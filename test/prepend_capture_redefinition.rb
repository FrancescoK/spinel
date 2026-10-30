# A capture pins a definition even when a prepend and redefinition follow.
module RedefinitionCaptureLayer
  def speak = "L " + super
end
class RedefinitionCaptureVoice
  def speak = "k1"
end
def capture_redefined(k) = k.method(:speak)
k = RedefinitionCaptureVoice.new
known = k.method(:speak)
before = capture_redefined(k)
class RedefinitionCaptureVoice
  prepend RedefinitionCaptureLayer
end
after_prepend = capture_redefined(k)
class RedefinitionCaptureVoice
  def speak = "k2"
end
after_redefinition = capture_redefined(k)
p known.call, before.call, after_prepend.call, after_redefinition.call
