# IO#gets sets $_ in CRuby and does not here: a program that reads $_
# after `$stdin.gets` is refused, not answered with a nil $_.
s = $stdin.gets
acc = []
begin
  s.scan(/./) { |m| acc << m; m << "!"; $_ << "z" if acc.size == 1 }
  p acc
rescue => e
  p [e.class, e.message]
end
p s
