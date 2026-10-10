# spinel: share
# spinel: gc-minor
# Exception text keeps the selected result and its identity.
class A < StandardError
  def to_s = "a"
end
def id(s) = s
def mka(s)
  id(s) << "y"
  A.new
end
v = +"vv"
j = mka(v).to_s
begin
  j << "!"
rescue FrozenError
  p :frozen
end
p j, v
x = A.new.message
