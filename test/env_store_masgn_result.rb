# A local written by a multiple assignment holds whatever the right side
# held: a boxed value with plain bytes, shared with another name, needs a
# handle for the returned alias, as a plain write's does.
def pick(i, s) = i > 0 ? s : 5
pick(0, {a: 1})
text = pick(ARGV.size + 1, "c" * 2)
value, count = text, 1
result = (ENV["SPINEL_SHARE_ENV_MASGN"] = value)
result << "!"
p text, result, count
ENV.delete("SPINEL_SHARE_ENV_MASGN")
