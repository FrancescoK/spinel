# Fresh conditional writes keep the only read eligible for ENV's result.
value = nil
value ||= +"q"
r = (ENV["SPINEL_ENV_FRESH"] = value)
r << "?"
p r
value2 = +"old"
value2 &&= +"a"
r2 = (ENV["SPINEL_ENV_FRESH"] = value2)
r2 << "!"
p r2
# A boxed String elsewhere must not change the fresh write's answer.
def pick(i, s) = i > 0 ? s : 5
pick(0, {a: 1})
text = pick(ARGV.size + 1, "d" * 2)
value3 = nil
value3 ||= +"dd"
r3 = (ENV["SPINEL_ENV_FRESH"] = value3)
r3 << "?"
p text, r3
value4, count = +"m", 1
r4 = (ENV["SPINEL_ENV_FRESH"] = value4)
r4 << "!"
p r4, count
value5 = nil
value5, count2 = +"n", 2
r5 = (ENV["SPINEL_ENV_FRESH"] = value5)
r5 << "!"
p r5, count2
value6 = nil
value6 = +"dd" if value6.nil?
r6 = (ENV["SPINEL_ENV_FRESH"] = value6)
r6 << "?"
p r6
ENV.delete("SPINEL_ENV_FRESH")
