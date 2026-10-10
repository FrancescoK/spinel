# A new String passed into a parameter other names share is boxed as the
# handle: boxed as its bytes, the append the method makes through the
# parameter reaches only the box's copy.
def append(a = nil, *rest, last)
  a << "!" if a.is_a?(String)
  [rest.size, last]
end
s = +"seed"
p append(s, 1)
p s
p append(+"fresh", *[1, 2], 3)
