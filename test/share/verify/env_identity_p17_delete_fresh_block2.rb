v = ENV.delete("RVENV_E2") { |m| m + "x" }
v << "y"
p v
w = ENV.delete("RVENV_E2") { +"lit" }
w << "y"
p w
