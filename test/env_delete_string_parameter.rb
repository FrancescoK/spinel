# spinel: gc-minor
# A missing ENV key binds a String, including when the block appends to it.
ENV.delete("SPINEL_ENV_DELETE_STRING_PARAM")
ENV.delete(+"SPINEL_ENV_DELETE_STRING_PARAM") { |missing| missing << "!"; p missing }
def env_fresh_key = +"SPINEL_ENV_DELETE_STRING_PARAM"
ENV.delete(env_fresh_key) { |missing| missing << "?"; p missing }
key = +"SPINEL_ENV_DELETE_STRING_PARAM"
ENV.delete(key) { |missing| missing << "!"; p missing }
