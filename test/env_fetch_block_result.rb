# A missing-key fetch block also returns its supplied key unchanged.
key = +"SPINEL_SHARE_ENV_FETCH_BLOCK"
ENV.delete(key)
result = ENV.fetch(key) { |missing| missing }
result << "!"
p key, result
ENV.delete("SPINEL_SHARE_ENV_FETCH_BLOCK")
