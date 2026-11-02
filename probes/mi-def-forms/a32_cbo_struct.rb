P = Struct.new(:x, :y) do
  p members
  p name
end
p P.new(1, 2).x
