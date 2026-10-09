$log = +""
def k(n); $log << "k#{n};"; "RVENV_O#{n}"; end
def v(n); $log << "v#{n};"; +"val#{n}"; end
ENV[k(1)] = v(1)
r = ENV.store(k(2), v(2))
r << "x"
t = (ENV[k(3)] = v(3))
t << "y"
p $log, r, t, ENV["RVENV_O1"], ENV["RVENV_O2"], ENV["RVENV_O3"]
ENV.delete("RVENV_O1"); ENV.delete("RVENV_O2"); ENV.delete("RVENV_O3")
