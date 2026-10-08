# A boxed defined? cannot distinguish an unset slot from one holding nil
# when ordinary and reflective writes share a name without a presence bit.
class Object
  def note=(v)
    @note = v
  end
  def note_defined = defined?(@note)
end
class DeclaredNote
  def initialize = (@note = nil)
end
class EmptyNote
end
DeclaredNote.new
x = EmptyNote.new
p x.note_defined
x.note = nil
p x.note_defined
