# spinel: gc-minor
# Method objects retain the definition selected when they are constructed.
module CaptureLayer
  def speak = "L " + super
end
class CaptureVoice
  def speak = "d"
end
def capture_voice(d) = d.method(:speak)
def voice_metadata(d)
  m = d.method(:speak)
  p m.owner.name, m.parameters, m.original_name
  p m.owner.class
  p m.owner == CaptureLayer ? :module : m.owner.new.speak
end
def capture_bind(d) = CaptureVoice.instance_method(:speak).bind(d)
def invoke_unbound(d) = CaptureVoice.instance_method(:speak).bind_call(d)
def capture_proc(d) = d.method(:speak).to_proc
def retain_voice(&b) = b
def capture_voice_block(d) = retain_voice(&d.method(:speak))
d = CaptureVoice.new
voice_metadata(d)
before = d.method(:speak)
saved = capture_voice(d)
bound = capture_bind(d)
proc_before = capture_proc(d)
block_before = capture_voice_block(d)
p invoke_unbound(d)
u = CaptureVoice.instance_method(:speak)
p before.call, u.bind(d).call, u.bind_call(d)
p d.public_method(:speak).call
p [1].map { d.method(:speak).call }
def invoke_voice = yield
p invoke_voice(&d.method(:speak))
class CaptureVoice
  prepend CaptureLayer
end
voice_metadata(d)
after = capture_voice(d)
p before.call, saved.call, after.call
p d.method(:speak).call, CaptureVoice.instance_method(:speak).bind(d).call
p CaptureVoice.instance_method(:speak).bind_call(d)
p u.bind(d).call, u.bind_call(d)
p d.public_method(:speak).call

p bound.call, capture_bind(d).call, invoke_unbound(d)
p proc_before.call, capture_proc(d).call
p block_before.call, capture_voice_block(d).call
