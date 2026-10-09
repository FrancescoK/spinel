# A case/when with a proc calls it with the subject, which changes it.
s = +"ab ab ab"; pr = proc { |x| x << "Z"; false }
kept = []
begin
  s.scan(/ab/) { |m| m << "!"; kept << m; case s; when pr then 1; end }
rescue RuntimeError => e
  p e.message
end
p kept, s
