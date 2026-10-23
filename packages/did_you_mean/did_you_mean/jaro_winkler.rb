module DidYouMean
  # How alike two Strings are, from 0 (nothing in common) to 1.0 (equal).
  module Jaro
    def self.distance(str1, str2)
      Comparison.new(str1.codepoints, str2.codepoints).distance
    end

    # Two Strings as codepoints, the shorter one first, and the pairs of
    # positions where their characters match.
    class Comparison
      def initialize(chars1, chars2)
        @short, @long = chars1.size > chars2.size ? [chars2, chars1] : [chars1, chars2]
        @pairs = matches
      end

      def distance
        return 0 if @pairs.empty?

        average(share_of(@short), share_of(@long), in_order)
      end

      private

      def average(*values) = values.inject(:+) / values.size

      def matched = @pairs.size.to_f

      def share_of(chars) = matched / chars.size

      def in_order = (matched - transpositions) / matched

      # Each character of the short String matches the first equal one of
      # the long String that is near it and not matched yet.
      def matches
        taken = []
        @short.each_index.filter_map do |i|
          j = near(i).find { !taken[it] && @long[it] == @short[i] }
          next unless j

          taken[j] = true
          [i, j]
        end
      end

      # The positions of the long String at most half its length, less one,
      # away from i.
      def near(i)
        reach = [@long.size / 2 - 1, 0].max
        [i - reach, 0].max..i + reach
      end

      # A transposition swaps two matched characters, so it puts two out of
      # place.
      def transpositions = out_of_place / 2

      # The matched characters read along each String, compared one by one.
      def out_of_place
        along_short = @pairs.map { @short[it.first] }
        along_long = @pairs.map(&:last).sort.map { @long[it] }
        along_short.zip(along_long).count { |a, b| a != b }
      end
    end
  end

  # Jaro, raised for a common prefix: each common character, up to
  # PREFIX_LIMIT, closes WEIGHT of the gap to 1.0. Only a distance above
  # THRESHOLD is raised.
  module JaroWinkler
    WEIGHT       = 0.1
    THRESHOLD    = 0.7
    PREFIX_LIMIT = 4

    def self.distance(str1, str2)
      jaro = Jaro.distance(str1, str2)
      return jaro if jaro <= THRESHOLD

      gap = 1 - jaro
      jaro + common_prefix(str1, str2) * WEIGHT * gap
    end

    def self.common_prefix(str1, str2)
      pairs = str1.codepoints.zip(str2.codepoints).first(PREFIX_LIMIT)
      pairs.take_while { |a, b| a == b }.size
    end
  end
end
