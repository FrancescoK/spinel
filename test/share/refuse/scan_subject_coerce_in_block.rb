# An implicit coerce call changes the subject through a global.
$s = +"ab ab ab"; s = $s; class O; def coerce(x); $s << "Z"; [x, 1]; end; end; o = O.new
kept = []
begin
  s.scan(/ab/) { |m| m << "!"; kept << m; x = 1 + o }
rescue RuntimeError => e
  p e.message
end
p kept, s
