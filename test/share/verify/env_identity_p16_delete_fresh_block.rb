k2 = +"RVENV_E2"
v = ENV.delete(k2) { |m| m + "x" }
v << "y"
p k2, v
