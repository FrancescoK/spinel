# A local written by `||=` holds whatever the right side held: a boxed value
# with plain bytes, shared with another name, needs a handle for the
# returned alias, as a plain write's does.
def pick(i, s) = i > 0 ? s : 5
pick(0, {a: 1})
text = pick(ARGV.size + 1, "d" * 2)
value = nil
value ||= text
result = (ENV["SPINEL_SHARE_ENV_OR_WRITE"] = value)
result << "?"
p text, result
ENV.delete("SPINEL_SHARE_ENV_OR_WRITE")
