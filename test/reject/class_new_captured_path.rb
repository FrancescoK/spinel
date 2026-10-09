# A namespaced constant assignment also never completes after a deferred raise.
# spinel: reject-subclass: block that captures outer locals
module CaptureSpace; end
value = 3
CaptureSpace::CapturedClass = Class.new { define_method(:value) { value } }
p CaptureSpace::CapturedClass.new.value
