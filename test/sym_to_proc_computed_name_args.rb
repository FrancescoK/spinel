# Symbol#to_proc's lambda takes the receiver and hands the rest to the
# method, for a Symbol held in a variable and built at run time as for a
# literal one
center = ("cen" + "ter").to_sym
pr = center.to_proc
p pr.call("ab", 6)
p pr.("ab", 6, "*")
p pr["ab", 4]
p center.to_proc.call("ab", 8, "-")

# a method taking two arguments, and one taking none
ins = "insert".to_sym
p ins.to_proc.call(+"ac", 1, "b")
up = "upcase".to_sym
upr = up.to_proc
p upr.call("ab")
p %w[x y].map(&upr)

# a count the method refuses is its own ArgumentError
begin
  pr.call("ab")
rescue ArgumentError => e
  p e.message
end

# it reports Symbol#to_proc's arity, and is a lambda
p pr.arity
p pr.lambda?

# no receiver at all
begin
  pr.call
rescue ArgumentError => e
  p e.message
end
begin
  :upcase.to_proc.call
rescue ArgumentError => e
  p e.message
end
