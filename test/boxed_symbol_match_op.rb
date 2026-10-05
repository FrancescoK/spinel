# =~ and !~ on a value read out of a mixed Array: a Symbol matches its name
# (setting $~), nil answers nil (!~ true), and any other kind raises
# NoMethodError naming its class.
x = [:hello, 1][0]
p x =~ /ll/
p $~
p x =~ /zz/
p x !~ /zz/
p x !~ /ll/
s = [+"hello", 1][0]
p s =~ /l+/
p $~[0]
n = [nil, 1][0]
p n =~ /a/
p n !~ /a/
def t
  p yield
rescue NoMethodError => e
  puts e.message
end
t { [1, :a][0] =~ /a/ }
t { [1, :a][0] !~ /a/ }
t { [true, :a][0] =~ /a/ }
if x =~ /h(e)/
  p $1
end
