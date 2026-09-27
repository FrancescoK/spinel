# A local that holds `x || {}` is boxed, and a Hash walk over it binds each
# key and value boxed. Its block params were typed from the round that still
# read the local as the `{}` arm's Hash of String keys, and kept that type
# once the local turned boxed, so a Symbol key was assigned to a String.
Stage = Struct.new(:outcomes)

def keys_of(stage)
  h = stage.outcomes || {}
  p h.transform_keys(&:to_s)
  p h.transform_keys { |k| k.to_s }
  h.each_key { |k| p k }
end

def values_of(stage)
  h = stage.outcomes || { "x" => "y" }
  p h.transform_values(&:to_s)
  p h.transform_values { |v| v.to_s }
  h.each_value { |v| p v }
end

def prune(stage)
  h = stage.outcomes || {}
  p h.dup.delete_if { |k, v| k == :a }
  p h.dup.keep_if { |k, v| k == :a }
  p h.dup.select! { |k, v| k == :a }
  p h.dup.filter! { |k, v| k == :a }
  p h.dup.reject! { |k, v| k == :a }
end

[Stage.new({ a: "added", b: "gone" }), Stage.new(nil)].each do |stage|
  keys_of(stage)
  prune(stage)
end
values_of(Stage.new({ a: 1, b: 2 }))
values_of(Stage.new(nil))
