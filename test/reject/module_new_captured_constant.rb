# A captured outer local is refused for Module.new as it is for Class.new.
# spinel: reject-subclass: block that captures outer locals
value = 5
CapturedModule = Module.new do
  define_method(:value) { value }
end
class CapturedModuleUser; include CapturedModule; end
p CapturedModuleUser.new.value
