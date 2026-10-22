module DidYouMean
  # The number of characters to insert, delete or replace to turn one String
  # into the other.
  module Levenshtein
    # EDIT is the cost of an insertion, deletion or replacement.
    EDIT = 1

    def self.distance(str1, str2)
      target = str2.codepoints
      costs = (0..target.size).to_a
      str1.codepoints.each_with_index do |char, i|
        costs = next_costs(costs, char, i + 1, target)
      end
      costs.last
    end

    # costs[j] is what it takes to turn the characters read so far into the
    # first j characters of the target. One character more is deleted, or
    # one of the target inserted, or the one replaced by the other.
    def self.next_costs(before, char, read, target)
      costs = [read]
      target.each_with_index do |other, j|
        deletion = before[j + 1] + EDIT
        insertion = costs[j] + EDIT
        replacement = before[j] + (char == other ? 0 : EDIT)
        costs << [deletion, insertion, replacement].min
      end
      costs
    end
  end
end
