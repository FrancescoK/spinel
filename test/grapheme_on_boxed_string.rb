# grapheme_clusters and each_grapheme_cluster on a String the compiler only
# knows as boxed (read out of a mixed Array) raised NoMethodError: only a
# receiver typed String was turned into chars / each_char. A boxed receiver
# now reaches the poly chars / each_char arms.
mixed = [1, "cd", "eé"]
s = mixed[1]
p s.grapheme_clusters
r = []
s.each_grapheme_cluster { |g| r << g }
p r
p s.each_grapheme_cluster.to_a
p s.each_grapheme_cluster.map(&:upcase)
p mixed[2].grapheme_clusters.size

# not a String at run time: still a NoMethodError
begin
  mixed[0].grapheme_clusters
rescue NoMethodError => e
  puts e.class
end
