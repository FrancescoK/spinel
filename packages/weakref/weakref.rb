# frozen_string_literal: true

# WeakRef as CRuby's weakref.rb has it, with weakref_alive?, __getobj__ and
# RefError. Two differences. CRuby's collector may recycle the object once
# nothing else refers to it, after which the reference raises RefError;
# Spinel's hands out no weak references, so the object lives as long as its
# WeakRef and weakref_alive? is always true. And CRuby's WeakRef is a
# Delegator, forwarding every other call to the object through
# method_missing, which Spinel does not dispatch (docs/limitations.md): read
# the object with __getobj__ and call it.
class WeakRef
  VERSION = "0.1.4"

  class RefError < StandardError
  end

  def initialize(orig)
    @delegate_sd_obj = orig
    # true, false and nil are kept as CRuby keeps them, in the ivar alone,
    # where weakref_alive? answers defined?'s word for it
    @immediate = case orig
                 when true, false, nil then true
                 else false
                 end
  end

  def __getobj__
    @delegate_sd_obj
  end

  # a no-op, as CRuby's: the reference is to the object given at creation
  def __setobj__(obj)
  end

  def weakref_alive?
    @immediate ? "instance-variable" : true
  end

  def ==(other)
    other.equal?(self) || @delegate_sd_obj == other
  end

  def !=(other)
    !(self == other)
  end

  def inspect
    @delegate_sd_obj.inspect
  end

  def to_s
    @delegate_sd_obj.to_s
  end
end
