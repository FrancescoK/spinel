# spinel: gc-minor
# An inherited Object method holds self boxed. Its ivars belong to the
# receiver's layout, and a receiver without the ivar reads nil.
class Object
  def stored = @stored
  def store(v) = (@stored = v)
  def default_store(v) = (@stored ||= v)
  def stored_default(v = @stored) = v
  def lazy_store = (@stored ||= ($default_calls += 1; 18))
end
class Slot
  def initialize(v) = (@stored = v)
  def peek = @stored
end
class OtherSlot
  def initialize(v) = (@stored = v)
end
class EmptySlot
end
class OwnReader
  def stored = 99
end
values = [Slot.new(1), OtherSlot.new(2.5), Slot.new(nil), Slot.new(false), Slot.new(true),
          EmptySlot.new, OwnReader.new, 5, nil, false, :symbol, [], {}, Object.new]
p values.map { |v| v.stored }

# A direct known-class call still enters the boxed Object method.
a = Slot.new(3)
p a.stored, a.store(4), a.peek, a.default_store(9), a.peek
p a.store(nil), a.stored, a.default_store(6), a.peek
p a.store(false), a.stored, a.default_store(7), a.peek
p a.store(true), a.default_store(8), a.peek
p a.stored_default, a.stored_default(19)
$default_calls = 0
p a.lazy_store, $default_calls
a.store(false)
p a.lazy_store, $default_calls
p a.lazy_store, $default_calls
p a.store("written"), a.stored

# The existing reflective set inference can also lay out a new slot.
e = EmptySlot.new
p e.stored, e.store(10), e.stored
p e.default_store(11), e.stored
b = Object.new
p b.stored, b.store(12), b.stored
arr = []
p arr.stored, arr.store(13), arr.stored

# Ivar syntax must bypass a program's reflective-method overrides.
class OverrideReflection
  def initialize = (@stored = 14)
  def instance_variable_get(name) = 90
  def instance_variable_set(name, value) = 91
  def instance_variable_defined?(name) = false
end
o = OverrideReflection.new
p o.stored, o.store(15), o.stored

# String contents are tested without observing identity across names.
class TextSlot
  def initialize = (@text = +"text")
end
class Object
  def stored_text = @text
end
t = TextSlot.new
p t.stored_text, [t, 5].map { |v| v.stored_text }

# Kernel methods copied into Object use the same boxed receiver ABI.
module Kernel
  def kernel_stored = @stored
end
p a.kernel_stored, 5.kernel_stored

# A BasicObject reopening with its typed ABI uses the same builtin calls.
class BasicObject
  def base_stored = @base_stored
  def base_store(v) = (@base_stored = v)
end
class BlankSlot < BasicObject
  def initialize = (@base_stored = 16)
end
blank = BlankSlot.new
p blank.base_stored, blank.base_store(17), blank.base_stored
