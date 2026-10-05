# io.write(*parts) and io.print(*parts) on a typed IO write each element of
# the splat in turn: the splat was read as one operand and the Array's
# inspect was written (#7313).
def wr(io, *parts) = io.write(*parts)
def pr(io, *parts) = io.print(*parts)
def pu(io, *parts) = io.puts(*parts)

r, w = IO.pipe
a = ["x", :y, 3]
p wr(w, "ab", "cd")
p w.write("<", *a, ">")
p w.write(*a)
p w.write(*[])
pr(w, "p", 1, nil)
w.print(*a)
w.print("[", *a, "]")
pu(w, "q", 2)
w.puts(*a)
w.close
p r.read

$stdout.write(*a, "\n")
$stdout.print(*a, "\n")
STDOUT.puts(*a)
print(*a, "\n")
