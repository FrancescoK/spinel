# Constant assignments have the same capture boundary as anonymous classes.
# spinel: reject-subclass: block that captures outer locals
value = 3
CapturedClass = Class.new { define_method(:value) { value } }
p CapturedClass.new.value
