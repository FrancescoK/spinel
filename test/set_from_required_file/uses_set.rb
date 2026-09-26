# A required file that names Set, with no `require "set"` anywhere in the
# program: CRuby provides Set without one, and the implicit splice has to
# see the reference here, not only in the entry file.
class Exclusions
  def initialize = @seen = Set.new
  def add(x) = (@seen << x; self)
  def size = @seen.size
end
