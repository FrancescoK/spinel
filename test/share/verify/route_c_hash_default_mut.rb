s = +"abc"
t = s
h = Hash.new(s); h[:z] << "!"
p s
p t
