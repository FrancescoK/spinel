# delete on a String Array with a needle read out of a container deletes an
# equal plain String and answers it, and answers nil (the block's value with
# a block) for a String that is not there or a value of another kind, as
# CRuby does, where the C build failed.
a = ["x", "y", "z"]
n = ["y", 1][0]
p a.delete(n)
p a
m = [2, "s"][0]
p a.delete(m)
p a.delete([:x, 1][0])
p a.delete(["q", 1][0])
p a.delete([nil, 1][0]) { :missing }
p a.delete(["z", 1][0]) { :missing }
p a
