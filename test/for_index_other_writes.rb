# A `for` index is an ordinary local: an assignment to it outside the loop,
# before or after, and another `for` that binds it as part of a destructure
# all share its one slot, so the slot has to hold every one of their types.

for t in [7]; end
t = "x"
p t

h = {a: 1}
for k, v in h; end
for k in [1]; end
p k, v

x = "pre"
for x in [1, 2]; end
p x

def after_loop
  for w in ["a", "b"]; end
  w = 3
  w += 1
  p w
  for i in 1..3; end
  i = nil
  p i
end
after_loop

for pr in {1 => "one"}; end
p pr
pr = 5
p pr

for a, b in [[1, "s"]]; end
a = "z"
p a, b
