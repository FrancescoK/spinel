class SV; def value = +"ab"; end
class IV; def value = 7; end
objects = [SV.new, IV.new]
r = ENV.store("RVENV_W4", objects[0].value)
r << "!"
p r
v = objects[0].value
r2 = ENV.store("RVENV_W5", v)
r2 << "?"
p r2
ENV.delete("RVENV_W4"); ENV.delete("RVENV_W5")
