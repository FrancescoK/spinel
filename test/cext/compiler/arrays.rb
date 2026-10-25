# frozen_string_literal: true
require_relative 'arrays'

source = [1, :two, "three", nil, 5.0]
[[0, 2], [1, 3], [3, 10], [5, 1], [5, 0], [6, 1], [-1, 1], [1, -1]].each do |b, n|
  p [b, n, CextArrays.subseq(source, b, n)]
end
slice = CextArrays.subseq(source, 0, 2)
slice << :more
p source
p slice
p CextArrays.fresh

tokens = {false => 0, :error => 1, "*" => 3, "+" => 5, :NUMBER => 9}
[false, :error, "*", "+", :NUMBER, "-", nil, :other].each do |key|
  p [key, CextArrays.lookup(tokens, key)]
end
counts = Hash.new(0)
counts[:seen] = 2
p [CextArrays.lookup(counts, :seen), CextArrays.lookup(counts, :unseen)]
doubled = Hash.new { |hash, key| key * 2 }
p CextArrays.lookup(doubled, 21)
p doubled
