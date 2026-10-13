# A missing-key block returns the key itself. Copying its result loses identity.
key = +"SPINEL_SHARE_ENV_DELETE_RESULT"
ENV.delete(key)
result = ENV.delete(key) { |missing| missing }
result << "!"
p key, result
ENV.delete("SPINEL_SHARE_ENV_DELETE_RESULT")
