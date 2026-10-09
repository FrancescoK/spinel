ENV["RVENV_U6"] = "x"
k = +"RVENV_U6"
v = ENV.delete(k) { |m| m }
p v, k
