v = ENV.fetch("RVENV_Z") { |m| m + "x" }
p v
w = ENV.delete("RVENV_Z") { |m| m + "x" }
p w
