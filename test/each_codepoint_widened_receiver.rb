# each_codepoint with a block on a parameter that is first seen as a String
# and later also takes a String out of a mixed Array: the walk runs for both
# callers. did_you_mean's JaroWinkler walks a word this way.
def total(s)
  n = 0
  s.each_codepoint { |c| n += c }
  n
end

def prefix(word, other)
  others = other.codepoints
  i = 0
  word.each_codepoint do |c|
    c == others[i] && i < 4 ? i += 1 : break
  end
  i
end

def mixed = ["ab", :x].first

p total("ab")
p total(mixed)
p prefix("martha", "marhta")
p prefix(mixed, "abc")
p total("héllo")
