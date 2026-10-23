# A local subject that an Array also holds has another name, so the refusal stays.
s = +"ab ab"
box = [s]
kept = []
begin
  s.scan(/ab/) { |m| kept << m; m << "!"; box[0] << "Z" if kept.size == 1 }
rescue RuntimeError => e
  p e.message
end
p kept, s
