# spinel: share
# spinel: gc-minor
# spinel: gc-stress
# A splat supplies defaults positionally, including run-time-length arrays.
p Hash.new(*[5])[1]
p Hash.new(*[])[1]
def hash_forward(*args) = Hash.new(*args)
p hash_forward(6)[1]
p hash_forward[1]
a = [7, 8]
a.pop
p Hash.new(*a)[1]
p Hash.new(*a.take(1))[1]
begin
  hash_forward(1, 2)
rescue ArgumentError
  p 99
end

def capacity_amount
  p 42
  4
end
def hash_capacity_forward(*args) = Hash.new(*args, capacity: capacity_amount)
p hash_capacity_forward(8)[1]
p hash_capacity_forward[1]
begin
  hash_capacity_forward(1, 2)
rescue ArgumentError
  p 99
end
