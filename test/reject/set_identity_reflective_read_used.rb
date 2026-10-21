# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# An identity Set kept in an instance variable and read back by a name the
# program computes: the read may answer the Set, and a String added through
# it has an identity that is not CRuby's. Refused at compile time.
require "set"

class Visits
  def initialize = @seen = Set.new.compare_by_identity
  def visit(n) = @seen << n
  def peek(name) = instance_variable_get(name) << "late"
end

v = Visits.new
v.visit(Object.new)
v.peek([:@seen].first)
