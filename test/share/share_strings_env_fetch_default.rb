# spinel: gc-minor
# An unset ENV name returns the default object itself.
ENV.delete("SPINEL_SHARE_ENV_FETCH_DEFAULT")
value = +"default"
result = ENV.fetch("SPINEL_SHARE_ENV_FETCH_DEFAULT", value)
result << "!"
p value, result
ENV.delete("SPINEL_SHARE_ENV_FETCH_DEFAULT")
