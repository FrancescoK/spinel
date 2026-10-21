# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# A Set written by a computed name may replace an identity Set an instance
# variable holds, so the identity Set is no longer followed where it lives,
# and the check returns to every Set's calls: the String looked up is
# refused. Refused at compile time.
require "set"

class Visits
  def initialize = @seen = Set.new.compare_by_identity
  def seen?(n) = @seen.include?(n)
  def swap(name) = instance_variable_set(name, Set["one"])
end

v = Visits.new
v.swap([:@seen].first)
p v.seen?("one")
