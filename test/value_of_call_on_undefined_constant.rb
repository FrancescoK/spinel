# A method whose value is a call on a constant defined nowhere raises
# NameError when it runs, so it answers nothing; one that answers it in a
# branch beside a real value still answers that value elsewhere (the timeout
# gem's `def self.instance` arm for a Ractor API a program may not have).
class Slot
  def self.shared = SpinelNoSuchStore.fetch(:k) { Slot.new }
  def self.pick(other) = other ? shared : Slot.new
  def label = "slot"
end
p Slot.pick(false).label
begin
  Slot.pick(true)
rescue NameError => e
  p e.class
end
