s = +"abc"
t = s
binding.local_variable_get(:s) << "!"
p s
p t
