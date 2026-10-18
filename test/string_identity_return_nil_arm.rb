# A method that answers its parameter on one path and nil on another hands
# the caller's String over on the first: the append through t changes s in
# CRuby. The result would be a copy, so the program is refused.
def maybe(s, flag)
  if flag
    s
  end
end
s = +"a"
t = maybe(s, true)
t << "!"
p s
