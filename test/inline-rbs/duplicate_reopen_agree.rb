# A method annotated the same way in two openings of its class, the second
# definition replacing the first. The annotations agree, so there is no
# message, and the resulting method keeps the signature. The --rbs binder
# refuses a name-based seed for a redefined method, so it is not a control.
class K
  #: (untyped) -> untyped
  def m(x) = x
end

class K
  #: (untyped) -> untyped
  def m(x) = x
end

p K.new.m(3)

# Agreeing replacements retain the live reader's pin without pinning the
# backing ivar of the body that no longer runs.
class Box
  def initialize
    @old = "ok"
    @new = [1]
  end

  #: () -> Array[Integer]
  def values = @old
end

class Box
  #: () -> Array[Integer]
  def values = @new

  def old = @old
end

box = Box.new
p box.old, box.values
