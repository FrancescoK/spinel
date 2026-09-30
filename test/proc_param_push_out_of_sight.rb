# A proc literal's parameter that its body pushes into, or writes an element
# of, was typed from that use alone: `a << "x"` read as "a is a String
# array". A Proc handed to a method, or called through another local, is
# called where the binders cannot see, so nothing corrected the guess, and a
# String the call passed was laundered out of the slot as an array -- the
# push aborted and the element write crashed. Such a parameter is boxed;
# `<<` and `[]=` take whichever value arrives.

f = proc { |a| a << "x" }
def fw(pr, s) = pr.call(s)
p fw(f, +"s")
p fw(f, ["t"])

g = f
p g.call(+"u")

l = ->(a) { a.push("y"); a }
p fw(l, ["v"])

n = Proc.new { |a| a.insert(1, "w") }
p fw(n, +"ab")

e = proc { |a| a[0] = "z"; a }
p fw(e, [1, 2])
p fw(e, +"abc")

# two literals handed to the same method, one concatenating
q = proc { |a| a.concat([1]) }
u = proc { |b| b.unshift("u") }
p fw(q, [0]), fw(u, ["v"])

# still bound where every call is in sight
k = ->(acc) { acc << 1 }
p k.call([0])
p ->(acc) { acc << "q" }.call([])
