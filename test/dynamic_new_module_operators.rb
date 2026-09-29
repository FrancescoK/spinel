# A klass.new on a class chosen at run time keeps every CLASS instantiable,
# but a module has no instances: a module's == / <=> (rbnacl's
# KeyComparator, included into its key classes) was named by the runtime's
# object comparison dispatch as if it were a class's, and never emitted.
module Cmp
  def <=>(other) = key <=> other.key
  def ==(other) = key == other.key
end
class A
  include Cmp
  attr_reader :key
  def initialize(k = 1) = @key = k
end
class B
  include Cmp
  attr_reader :key
  def initialize(k = 2) = @key = k
end
kl = [A, B][ARGV.size]
x = kl.new
y = [A.new(5), B.new(5)][ARGV.size]
p x == A.new, (x <=> A.new(3)), y == B.new(5)
