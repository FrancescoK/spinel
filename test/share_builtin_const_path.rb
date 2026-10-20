# File::SEPARATOR is the builtin's own String, not a constant of the program
# that shares its leaf name (Q::SEPARATOR, changed in place): an argument
# a method keeps hands on the builtin's, and Q's stays Q's (#9258).
module Q
  SEPARATOR = +"::"
end
class File
  def self.twice(x) = [x, x]
end
class Keeper
  def initialize = @kept = []
  def keep(s) = (@kept << s; s)
  def kept = @kept
end
Q::SEPARATOR << "!"
k = Keeper.new
k.keep(File::SEPARATOR)
k.keep(Q::SEPARATOR)
p "a/b".split(File::SEPARATOR), ["a", "b"].join(File::SEPARATOR), k.kept, Q::SEPARATOR, k.kept[1].equal?(Q::SEPARATOR)
