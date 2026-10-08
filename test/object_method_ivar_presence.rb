# spinel: gc-minor
# Boxed Object reads use the existing presence facts for initialized slots
# and slots written only through reflection, including a stored nil.
class Object
  def note = @note
  def note=(v)
    @note = v
  end
  def note_defined = defined?(@note)
  def ready_defined = defined?(@ready)
  def reflect_note(v) = self.instance_variable_set(:@note, v)
end
class PresenceSlot
  def initialize = (@ready = nil)
end
x = PresenceSlot.new
p x.note, x.note_defined, x.ready_defined, 5.note_defined
x.note = nil
p x.note, x.note_defined

# A different class's ordinary writes do not disable this slot's set bit.
class DeclaredNote
  def initialize = (@note = nil)
end
class EmptyNote; end
class ChildNote < EmptyNote; end
DeclaredNote.new
fresh = EmptyNote.new
written = EmptyNote.new
p fresh.note_defined, fresh.instance_variable_defined?(:@note)
p fresh.instance_variables, fresh.inspect.include?("@note=")
written.note = nil
p written.note_defined, written.instance_variable_defined?(:@note)
p written.instance_variables, written.inspect.include?("@note=nil")
p fresh.note_defined, fresh.instance_variables, fresh.inspect.include?("@note=")
child = ChildNote.new
p child.note_defined
child.note = false
p child.note_defined, child.note, child.instance_variables
p [EmptyNote.new, written, child].map { |o| o.instance_variable_defined?(:@note) }
class NoteParent
  attr_reader :note, :tail
  def initialize = (@tail = 7)
end
class NoteChild < NoteParent; end
inherited = NoteChild.new
p inherited.note, inherited.tail, inherited.instance_variables
inherited.note = nil
p inherited.note, inherited.tail, inherited.instance_variables
p NoteParent.new.instance_variables
explicit = EmptyNote.new
p explicit.instance_variable_defined?(:@note)
explicit.reflect_note(nil)
p explicit.instance_variable_defined?(:@note), explicit.instance_variables
x.note = false
p x.note, x.note_defined
