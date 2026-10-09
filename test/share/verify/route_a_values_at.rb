s = +"abc"
r = {k: s}.values_at(:k)[0]
r << "!"
p s
p r
