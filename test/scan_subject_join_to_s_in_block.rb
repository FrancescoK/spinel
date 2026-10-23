# Array#join calls a to_s that changes the subject through a global.
$s = +"ab ab ab"; s = $s; class O; def to_s; $s << "Z"; "o"; end; end; o = O.new
kept = []
begin
  s.scan(/ab/) { |m| m << "!"; kept << m; x = [o].join }
rescue RuntimeError => e
  p e.message
end
p kept, s
