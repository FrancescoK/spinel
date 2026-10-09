class SV; def value = +"ab"; end
class IV; def value = 7; end
objects = [SV.new, IV.new]
v = objects[0].value
r2 = ENV.store("RVENV_W5", v)
r2 << "?"
p r2
ENV.delete("RVENV_W5")
