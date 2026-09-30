# A typed array a method built, passed to a boxed parameter (its callers
# disagree on the array kind) that the method stores a String into: the
# store promoted a copy to the general Array, and the caller's array never
# saw it. `x` printed [1, 2] where CRuby prints ["s", 2], and was then
# refused at compile time, since the binding widened only an array built
# where the call could see it. It now follows `x` back into `nums`.
def m(arr); arr[0] = "s"; end
def nums = [1, 2]
b = ["x"]
m(b)
x = nums
m(x)
p x
