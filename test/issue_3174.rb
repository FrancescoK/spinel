# spinel: share
require 'set'
h = { a: Set.new }
h[:a] << 1
p h[:a].to_a
adj = Hash.new { |hh, k| hh[k] = Set.new }
adj[:x] << 1
adj[:x] << 2
adj[:y] << 3
p adj[:x].to_a.sort
p adj[:y].to_a
