# spinel: gc-minor
# Mutating delete's missing-key parameter must change the supplied key.
key = +"SPINEL_SHARE_ENV_DELETE_PARAMETER"
ENV.delete(key)
ENV.delete(key) { |missing| missing << "!" }
p key
ENV.delete("SPINEL_SHARE_ENV_DELETE_PARAMETER")
