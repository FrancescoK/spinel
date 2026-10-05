# instance_variable_set on a String, which CRuby gives an instance
# variable of its own: Spinel copies a String between its representations
# and keeps no identity for the variable to live on, so it is refused
# rather than compiled without the variable.
s = +"s"
s.instance_variable_set(:@a, 1)
p s.instance_variable_get(:@a)
