class SV; def value = +"ab"; end
class IV; def value = 7; end
objects = [SV.new, IV.new]
r = ENV.store("RVENV_W4", objects[0].value)
r << "!"
p r
ENV.delete("RVENV_W4")
