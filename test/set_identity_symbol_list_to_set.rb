# In a program whose identity Set is handed on (so every Set's calls are
# checked), a constant Set made from a list of Symbols with to_set is no
# refusal: to_set is Set.new over the list's to_a, and the to_a of an Array
# holds the Array's own elements, Symbols here, whose identity is CRuby's.
require "set"

class Visits
  def initialize = @seen = Set.new.compare_by_identity
  def visit(n) = @seen << n
  def seen = @seen
end

module Spacing
  KINDS = %i[dot anddot].to_set.freeze
  PAIRS = [:open, :close].to_set
  def self.kind?(k) = KINDS.include?(k)
end

v = Visits.new
v.visit(:a)
v.visit(:a)
kept = v.seen
p kept.size
p Spacing.kind?(:dot), Spacing.kind?(:other)
p Spacing::PAIRS.include?(:open), Spacing::PAIRS.size
