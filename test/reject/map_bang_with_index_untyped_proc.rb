# map!.with_index on a String Array with its block given as a proc: the
# proc's value is boxed and may be any class, which the typed array the
# result is written back into cannot hold. Refused; it did not build.
s = ["a", "b"]
s.map!.with_index(&proc { |x, i| x * (i + 1) })
p s
