# An identity Set an attr_reader answers is followed through the reader's
# calls: objects added through it keep their identity, and another Set of
# the program keeps its String members.
require "set"

class Node; end

class Box
  attr_reader :seen
  def initialize = @seen = Set.new.compare_by_identity
end

b = Box.new
a = Node.new
b.seen << a
b.seen << Node.new
b.seen << a
p b.seen.size, b.seen.include?(a), b.seen.compare_by_identity?
t = Set.new
t << "str"
t << "str".dup
p t.size
