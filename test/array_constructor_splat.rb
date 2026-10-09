# spinel: share
# spinel: gc-minor
# spinel: gc-stress
# Constructor splats separate the size from the fill at either length.
p Array.new(*[2, 7])
p Array.new(*[])
p Array.new(*[3]) { |i| i + 1 }
def array_forward(*args) = Array.new(*args)
p array_forward(2, 7)
p array_forward
p array_forward(2)
y = [4]
y << 9
p Array.new(*y)
p Array.new(*y.take(2))
z = [8, 9]
z.pop
p Array.new(2, *z)
begin
  array_forward(1, 2, 3)
rescue ArgumentError
  p 99
end

# A block overrides the fill, including its inferred element representation.
p Array.new(*[2, 3]) { |i| i * 5 }
p Array.new(2, 3) { |i| i * 5 }
