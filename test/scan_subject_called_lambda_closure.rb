# A lambda that captured the local subject changes it when the block calls it.
s = +"ab ab"
l = -> { s << "Z" }
kept = []
begin
  s.scan(/ab/) { |m| kept << m; m << "!"; l.call if kept.size == 1 }
rescue RuntimeError => e
  p e.message
end
p kept, s
