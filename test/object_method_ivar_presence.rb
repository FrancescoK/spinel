# Boxed Object reads use the existing presence facts for initialized slots
# and slots written only through reflection, including a stored nil.
class Object
  def note = @note
  def note=(v)
    @note = v
  end
  def note_defined = defined?(@note)
  def ready_defined = defined?(@ready)
end
class PresenceSlot
  def initialize = (@ready = nil)
end
x = PresenceSlot.new
p x.note, x.note_defined, x.ready_defined, 5.note_defined
x.note = nil
p x.note, x.note_defined
x.note = false
p x.note, x.note_defined
