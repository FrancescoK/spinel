# Splatting an empty `[]` literal contributes no elements.
p [*[], "only"]
p [1, *[], 2]
p [*[], *[]]
p [*[1], *[]]
p [*[]]
p [*[[]], 1]
p [*[], :a, *[1, 2]]
x = [*[], 3]
p x.size
@i = [*[], 1.5]
p @i
s, t = *[], "only"
p s, t
