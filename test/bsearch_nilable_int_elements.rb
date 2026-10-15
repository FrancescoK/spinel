# bsearch and bsearch_index hand their block an element of an Integer
# Array that can hold nil (a running sum of an attribute's reads), whose
# parameter keeps its nil: a plain read wrote an sp_int into its sp_oint
# and the C did not compile (#9204, LangArena's arithmetic decoder).
class Enc
  attr_reader :frequencies
  def initialize(f) = @frequencies = f
end

def tables(encoded)
  frequencies = encoded.frequencies
  high = Array.new(4, 0)
  cum = 0
  4.times do |i|
    cum += frequencies[i]
    high[i] = cum
  end
  high
end

high = tables(Enc.new([1, 1, 1, 1]))
result = Array.new(3, 0)
3.times do |j|
  symbol = high.bsearch_index { |x| x > j + 1 }
  result[j] = symbol
end
p result
p high.bsearch { |x| x >= 3 }
p high.bsearch_index { |x| x > 9 }
p high.bsearch { |x| 2 <=> x }
f = Array.new(3, 0.0)
s = 0.0
3.times { |i| s += [0.5, 1.5, 2.5][i]; f[i] = s }
p f.bsearch { |x| x > 1.0 }
