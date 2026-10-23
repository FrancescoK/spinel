# spinel: share
s = "a\xffb c".b
p s.scan(/\S+/).map(&:encoding)
p s.scan(/(\S)(\S)/).flatten.map(&:encoding)
md = s.match(/(\S+) (c)/)
p [md[0], md[1], md[2], md.pre_match, md.post_match, md.to_s].map(&:encoding)
p md.captures.map(&:encoding)
p md.to_a.map(&:encoding)
if s =~ /(b) /
  p [$1, $~[0], $`, $'].map(&:encoding)
end
p s.partition(/ /).map(&:encoding)
p s.rpartition(/ /).map(&:encoding)
p s.split(/ /).map(&:encoding)
p s.sub(/a/, "x").encoding
p s.gsub(/a/, "x").encoding
p s.gsub(/a/) { "x" }.encoding
p s.slice(/b/).encoding
p s[/(b)/, 1].encoding
t = "héllo wörld"
p t.scan(/\S+/).map(&:encoding)
p t.match(/(\S+)/)[1].encoding
# a substitution through a Hash, and the empty fields of a partition that
# finds nothing, are in the subject's encoding too
p s.gsub(/b/, "b" => "x").encoding
p s.sub(/b/, "b" => "x").encoding
p s.partition(/z/).map(&:encoding)
p s.rpartition(/z/).map(&:encoding)
