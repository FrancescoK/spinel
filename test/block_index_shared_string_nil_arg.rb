# A method that yields and also calls its &block as `b[x]` or `b.yield(x)`
# takes the block as a proc, and a String parameter handed to an appending
# block there is the shared handle (#6486). A nil argument leaves that
# handle NULL: the proc call must hand the block nil, not read the NULL
# handle's bytes.
def ri(x, &b)
  return yield(x) if x && x.size > 50
  b[x]
end
def ry(x = nil, &b)
  return yield(x) if x && x.size > 50
  b.yield(x)
end
s = +"a"; ri(s) { |w| w << "!" if w }; p s
ri(nil) { |w| p w }
t = +"b"; ry(t) { |w| w << "?" if w }; p t
ry(nil) { |w| p w }
ry { |w| p w.nil? }
