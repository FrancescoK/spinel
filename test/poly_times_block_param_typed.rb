# times on a receiver typed poly types its block parameter during inference:
# a local assigned from it and from a String is boxed, not a String (it came
# out "s" for every element, the Integers silently read as strings).
def poly(i) = [3, "s", nil][i]
n = poly(0)
out = []
n.times do |i|
  if i.even?
    v = i * 10
  else
    v = "s"
  end
  out << v
end
p out
out2 = []
[0, 1, 2].each do |i|
  j = poly(0)
  if i.even?
    v = j * 10
  else
    v = "s"
  end
  out2 << v
end
p out2
