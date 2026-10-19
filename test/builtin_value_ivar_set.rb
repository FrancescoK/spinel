# instance_variable_set on a String gives it an instance variable of its
# own, as CRuby does: the runtime's table is keyed by the String's shared
# handle, which the share walk gives a String the reflection reaches.
s = +"s"
s.instance_variable_set(:@a, 1)
p s.instance_variable_get(:@a)
