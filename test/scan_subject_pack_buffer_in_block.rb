# Array#pack with the subject as its buffer writes the subject.
s = +"ab ab ab"
kept = []
begin
  s.scan(/ab/) { |m| m << "!"; kept << m; [65].pack("C", buffer: s) }
rescue RuntimeError => e
  p e.message
end
p kept, s
