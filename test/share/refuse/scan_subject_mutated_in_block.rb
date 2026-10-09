# CRuby raises "string modified" when the subject of a scan changes under it.
# A match the block keeps and changes is a shared String under the flag, but
# the scan's own subject is mutated by the same block, so the route stays refused.
acc = []
s = +"abc"
begin
  s.scan(/./) { |m| acc << m; m << "!"; s << "z" if m == "a!" }
rescue => e
  p e.class, e.message
end
p acc
