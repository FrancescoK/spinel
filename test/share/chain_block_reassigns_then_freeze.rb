# Under --share-strings (#6765): A tap block that assigns the local, then freeze: the String the chain started
# from is frozen, not the new one.
# a tap reassigning the local, then freeze: the original is frozen, not the new one
def m(v)
  s = +"abc"
  o = s
  x = s.tap { s = +"zz" }.freeze || v
  [x, o.frozen?, s.frozen?]
end
p m(1)
