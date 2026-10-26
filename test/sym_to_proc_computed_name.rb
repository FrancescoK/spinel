# A Symbol built at run time, whose name no literal spells, sent through
# Symbol#to_proc: `a.map(&name)` is a block sending the name to the block's
# parameter, and the parameter's methods are the dispatch's arms
size = ("si" + "ze").to_sym
up = ["up", "case"].join.to_sym
rev = "esrever".reverse.to_sym
p ["ab", "cde"].map(&size)
p ["ab"].map(&up)
p ["ab"].map(&up.to_proc)
p ["ab", "xyz"].map(&rev)
p [1, 41].map(&("su" + "cc").to_sym)
p %w[b a c].sort.each_with_object([]) { |s, acc| acc << s.send(up) }

# the block's further values are the method's arguments
plus = ("" + "+").to_sym
p [1, 2, 3].inject(&plus)
p [[1, 2], [3, 4]].map { |a, b| a.send(plus, b) }

# Symbol#to_proc called directly
p up.to_proc.call("ab")
pr = size.to_proc
p pr.call("abcd")
# ... and stored, from a name a literal spells and from a computed one
lit = "upcase".to_sym
pr = lit.to_proc
p pr.call("ab")
pr = up.to_proc
p pr.call("cd")

# a name no method answers raises CRuby's NoMethodError
missing = ("no_such" + "_meth").to_sym
begin
  ["ab"].map(&missing)
rescue NoMethodError => e
  p e.message
end
begin
  missing.to_proc.call("ab")
rescue NoMethodError => e
  p e.message
end
