# spinel: reject-subclass: a method defined in an instance_eval block
# A def in an instance_eval block defines a method on the receiver's
# singleton class. Here the receiver is a local, so the program names no
# singleton class the method can be registered on. The call is refused
# rather than the def landing somewhere else and answering wrongly.
class Shape; end
k = Shape
k.instance_eval { def sides = 4 }
p Shape.sides
