# A bare (receiverless) call to an attr_reader, nil-checked in an if, whose
# OWN if-branch assigns the backing ivar a concrete non-nil value through the
# paired writer: `id.nil?` must still be a real, per-call runtime check, not
# fold to a compile-time constant just because a sibling write settles the
# ivar's type to a concrete Integer/Float. `self.id.nil?` (explicit receiver,
# same method) already answered this correctly; the bare form did not
# (kilau K-017, found 2026-10-12 re-testing against bop_rows-#8650's master).
class Widget
  attr_accessor :id
  def save
    if id.nil?
      self.id = 99
      "assigned"
    else
      "already set"
    end
  end
end
p Widget.new.save
w2 = Widget.new
w2.id = 7
p w2.save
