# instance_variable_set on a String, which CRuby gives an instance
# variable of its own: Spinel copies a String rather than sharing it, so it
# has no identity for the variable yet (#6765), and the set is refused
# rather than compiled without the variable.
s = +"s"
s.instance_variable_set(:@a, 1)
p s.instance_variable_get(:@a)
