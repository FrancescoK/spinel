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
