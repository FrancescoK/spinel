# spinel: gc-stress
# A block an emitter inlines (sub!, gsub!) holds none of its own operands
# across the block: `m + t` there read both Strings as copies, neither
# rooted, and the second copy could collect the first
def id(v) = v
t = +"xy"
id(t).upcase!
s = +"abcb"
id(s).upcase!.sub!("B") { |m| m + t }
p s
id(s).downcase!.gsub!("b") { |m| t + m + t }
p s
u = +"pq"
u.gsub!(/q/) { |m| u.size.to_s + m + t }
p u, t
