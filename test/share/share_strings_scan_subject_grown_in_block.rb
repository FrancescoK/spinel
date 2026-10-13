# CRuby raises "string modified" when the subject of a scan changes under it.
# A match the block keeps and changes is a shared String under the flag; the
# block also grows the scan's own subject, which the run-time length check
# sees after that turn, raising as CRuby does.
acc = []
s = +"abc"
begin
  s.scan(/./) { |m| acc << m; m << "!"; s << "z" if m == "a!" }
rescue => e
  p e.class, e.message
end
p acc
