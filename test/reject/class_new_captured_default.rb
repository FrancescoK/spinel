# A block parameter default can capture an outer local too.
# spinel: reject-subclass: block that captures outer locals
value = 3
klass = Class.new do |base, captured = value|
  define_method(:value) { captured }
end
p klass.new.value
