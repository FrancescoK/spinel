# A boxed receiver that is a String or a module whose class method of the
# name answers an Array of another kind: the call's slot holds both Arrays
# (a String's split beside M.split's mixed Array), as the dispatch's arms
# write them.

module M
  def self.split(s) = [1, s]
end
h = {a: "x,y", b: M}
p h[:a].split(",")
p h[:b].split(",")
p h[:a].split(",").size + h[:b].split(",").size

# a module answering the builtin's own kind keeps it
module N
  def self.split(s) = ["n", s]
end
g = {a: "p,q", b: N}
p g[:a].split(",").map(&:upcase)
p g[:b].split(",").map(&:upcase)
