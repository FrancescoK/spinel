# spinel: share
# spinel: gc-minor
# Exception text keeps the selected result and its identity.
def id(s) = s
class A < StandardError
  def initialize(s)
    @s = s
    super()
  end
  def to_s
    id(@s) << "y"
    "a"
  end
end
v = +"vv"
j = A.new(v).to_s
begin
  j << "!"
rescue FrozenError
  p :frozen
end
p j, v
x = A.new(+"w").message
p x
