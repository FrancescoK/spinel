# spinel: share
# spinel: gc-minor
# A shallow Array copy keeps each element's identity. Keep the two mutation
# directions in separate scopes so one cannot make the other share by chance.
source = +"top"
original = [source]
copied = Array.new(original)
copied[0] << "!"
p source, original, copied
copied << +"other"
p original, copied

reverse_source = +"reverse"
reverse_copy = Array.new([reverse_source])
reverse_source << "?"
p reverse_copy

def copy_forward
  s = +"method"
  a = Array.new([s])
  a[0] << "!"
  p s
end

def copy_reverse
  s = +"method-reverse"
  a = [s]
  b = Array.new(a)
  s << "?"
  p b
end
copy_forward
copy_reverse

1.times do
  block_source = +"block"
  block_copy = Array.new([block_source])
  block_copy[0] << "!"
  p block_source
end
1.times do
  block_reverse = +"block-reverse"
  block_array = [block_reverse]
  block_copy_reverse = Array.new(block_array)
  block_reverse << "?"
  p block_copy_reverse
end

# The same copy can be read directly, or retain a nested container.
def direct_copy
  s = +"direct"
  t = Array.new([s])[0]
  t << "!"
  p s
end
def nested_copy
  s = +"nested"
  a = Array.new([[s]])
  a[0][0] << "!"
  p s
end
direct_copy
nested_copy

# A duplicated String stays separate and a literal stays frozen.
def distinct_elements
  s = +"distinct"
  a = Array.new([s, s.dup])
  a[1] << "!"
  p s, a
end
distinct_elements
frozen_copy = Array.new(["fixed"])
begin
  frozen_copy[0] << "!"
rescue FrozenError
  puts "frozen"
end

# Integer sizes and block results keep their existing meanings.
p Array.new(2)
p Array.new(2) { |i| i }
