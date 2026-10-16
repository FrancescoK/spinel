# A boxed nil written to a String? ivar that is appended to elsewhere (a
# shared handle slot) is the slot's nil, not a TypeError; a boxed String
# is wrapped as before (#9278).
class NilableOwnerSlot
  def owner_id=(value)
    @owner_id = value
  end

  def owner_id
    @owner_id
  end

  def tag!
    @owner_id << "!" unless @owner_id.nil?
  end
end

class NilableOwnerGadget
  def id
    "g-" + "1"
  end
end

class NilableOwnerSprocket
  def id
    7
  end
end

w = NilableOwnerSlot.new
w.owner_id = nil
p w.owner_id
owner = ARGV.length > 5 ? NilableOwnerSprocket.new : NilableOwnerGadget.new
w.owner_id = owner.id
w.tag!
p w.owner_id
