# spinel: gc-stress
# The value of gsub's and sub's block (and their bangs') is made from the
# block's own operands, which no call around the block holds: under a
# collection at every allocation the first of `m + m`'s operands was a
# copy nothing rooted while the second was made, and the answer read
# freed bytes.
def id(v) = v
s = +"WBCW"
r = []
40.times do
  r << s.sub("W") { |m| m + m }
  r << s.gsub(/[BC]/) { |m| m + m + m }
end
p r.uniq
t = +"abca"
t.gsub!(/a/) { |m| m + "!" }
t.sub!("b") { |m| m + m }
p t
u = +"wbcw"
id(u).upcase!.sub!("W") { |m| m + m }
p u
