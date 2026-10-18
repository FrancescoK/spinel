# A class of the program's own may define frozen?, and a value held boxed
# answers through it: the class's method for its objects, the builtin's for
# the rest (an Integer, a frozen or unfrozen String, an Array), also through
# a Method of frozen? or a send of a name known only at run time.

class Node
  def frozen? = :maybe
end

class Flag
  def initialize(v) = @v = v
  def frozen? = @v
end

vals = [1, "lit".freeze, +"dup", [1, 2], Node.new, Flag.new(true), Flag.new(false), nil]
vals.each { |v| p v.frozen? }
x = vals[ARGV.size + 4]
p x.method(:frozen?).call
p vals[ARGV.size].method(:frozen?).call
names = %i[frozen? class][0, 2 - ARGV.size]
names.each { |n| p vals[ARGV.size + 4].public_send(n) }
