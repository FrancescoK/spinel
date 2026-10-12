# min and max of an Integer array literal holding a splat take the
# extreme over the splatted elements too
lengths = [2, 4, 6, 8]
puts [7, *lengths].max
puts [7, *lengths].min
puts [*lengths, 9].max
puts [*lengths, 1].min
puts [*lengths, *lengths].max
puts [7, *[]].max
p [*[], *[]].max

tracks = { 1 => ["ab", 0], 2 => ["abcdefghijkl", 1] }
puts [5, *tracks.values.map { |bytes, _| bytes.length }].max
puts [5, *tracks.values.map { |bytes, _| bytes.length }].min
