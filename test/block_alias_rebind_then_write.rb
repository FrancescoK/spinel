# A block that copies its element into a local, rebinds that local, then
# writes another local. The rebinding clears the alias it tracked, and the
# next write compared its name with the cleared one: the compiler crashed.
a = [+"x", +"y"]
a.each do |s|
  t = s
  t = +"z"
  u = 1
  p [t, u]
end
p a
