k = +"RVENV_J1"
r = ENV.store(k, "lit")
k << "Z"
p r, k, ENV["RVENV_J1"]
ENV.delete("RVENV_J1")
