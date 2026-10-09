# A method reached through alias_method changes the subject it is given.
s = +"ab ab ab"; class O; def foo(x) = x << "Z"; alias_method :zork, :foo; end; o = O.new
kept = []
begin
  s.scan(/ab/) { |m| m << "!"; kept << m; o.zork(s) }
rescue RuntimeError => e
  p e.message
end
p kept, s
