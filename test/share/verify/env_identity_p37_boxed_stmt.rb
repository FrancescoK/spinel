class SV; def value = +"ab"; end
class IV; def value = 7; end
objects = [SV.new, IV.new]
v = objects[0].value
v << "c"
ENV.store("RVENV_Q3", v)
ENV["RVENV_Q4"] = v
v << "d"
p ENV["RVENV_Q3"], ENV["RVENV_Q4"], v
n = objects[1].value
begin
  ENV["RVENV_Q5"] = n
rescue TypeError => e
  p e.message
end
ENV.delete("RVENV_Q3"); ENV.delete("RVENV_Q4")
