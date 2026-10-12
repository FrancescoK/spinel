# File.join(*parts) where the length of parts is known only at run time:
# File.join takes any number of parts (Array#join takes one separator)
def relative(path)
  parts = File.dirname(path)
  parts = parts.split("/")
  parts << "x"
  File.join(*parts)
end
p relative("a/b/c")

v = [1, "s"].first == 1 ? ["p", "q", "r"] : "one"
p File.join(*v)
w = [1, "s"].last == 1 ? ["p"] : "one"
p File.join(*w)
p File.join("top", *v)
p File.join(*v, "end")

def joined(a) = File.join(*a)
p joined(["m", "n", "o"])
p joined([])

def parts = ["x", ["y", "z"]]
p File.join(*parts)

n = [1, "s"].first == 2 ? ["k"] : nil
p File.join(*n)

# a length known at compile time still expands
a = ["m", "n"]
p File.join(*a)
p File.join("r", *a)
