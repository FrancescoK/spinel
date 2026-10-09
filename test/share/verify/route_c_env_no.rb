s = +"abc"
t = s
ENV["RVB_Q"] = s; ENV["RVB_Q"].dup << "!"
p s
p t
