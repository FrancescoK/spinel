# A boxed receiver that is a String or a module with its own `split`: the
# call answers the boxed Array both arms fill. The String's split with a
# limit is the builtin's arm, its String Array moved into that boxed Array;
# it raised NoMethodError for the String.
module M
  def self.split(s, n) = [n, s]
end
h = {a: "x,y,z", b: M}
p h[:a].split(",", 2)
p h[:b].split(",", 2)
p h[:a].split(",", 2).size
p h[:a].split(",", 2).map(&:upcase)
