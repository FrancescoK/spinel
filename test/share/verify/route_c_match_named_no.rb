s = +"abc"
t = s
/(?<w>a)/ =~ s; w << "!"
p s
p t
