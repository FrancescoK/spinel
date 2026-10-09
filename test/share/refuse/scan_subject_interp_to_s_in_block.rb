# An interpolation inside the block calls a to_s that changes the global subject.
$s = +"ab ab ab"
class O; def to_s; $s << "Z"; "o"; end; end
O_ = O.new
kept = []
begin
  $s.scan(/ab/) { |m| m << "!"; kept << m; x = "#{O_}" }
rescue RuntimeError => e
  p e.message
end
p kept, $s
