s = +"abc"
t = s
$_ = s; $_ << "!"
p s
p t
