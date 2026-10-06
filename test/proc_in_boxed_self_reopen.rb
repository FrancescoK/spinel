# A block that becomes a proc of its own inside a method of an Object,
# Array or Hash reopening -- whose self is any value, held boxed --
# captures that boxed self: activesupport's Object#with runs its blocks
# this way. It was captured as a pointer to an Object struct.
class Object
  def self_getter = -> { self }
  def tagged = proc { |x| "#{x}:#{inspect}" }
end
class Array
  def size_getter = -> { size }
end
class Hash
  def key_getter = -> { keys }
end
p 5.self_getter.call, "s".self_getter.call, :a.tagged.call(1)
p [1, 2].size_getter.call, { a: 1 }.key_getter.call
