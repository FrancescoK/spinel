s = +"abc"
t = s
s =~ /a/; $~.string.frozen? || nil
p s
p t
