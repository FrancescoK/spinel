# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# In a program whose identity Set is handed on, a Set made with to_set from
# a list of Symbols is refused when the program gives Array a to_a of its
# own: to_set is Set.new over the list's to_a here, and that to_a may answer
# values of any kind, so the list's own elements do not tell its members.
require "set"

class Array
  def to_a = map(&:to_s)
end

class Visits
  def initialize = @seen = Set.new.compare_by_identity
  def seen = @seen
end

kept = Visits.new.seen
p kept.size
KINDS = %i[dot anddot].to_set
p KINDS.include?(:dot), KINDS.size
