# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# In a program whose identity Set is handed on, a Set made with to_set from
# a list of String literals is still refused: to_set is Set.new over the
# list's to_a, which holds the literals, whose identity is not CRuby's.
require "set"

class Visits
  def initialize = @seen = Set.new.compare_by_identity
  def seen = @seen
end

kept = Visits.new.seen
p kept.size
NAMES = %w[left right].to_set
p NAMES.include?("left")
