# spinel: gc-minor
# Reads keep ENV's copy separate. Missing-key blocks and defaults remain
# usable when no other name observes a String mutation through the result.
key = +"SPINEL_SHARE_ENV_READS"
value = +"original"
ENV.store(key, value)
value << "!"
p ENV[key], value
p ENV.fetch(key, "unused")
p ENV.key("original")
p ENV.assoc(key)
p ENV.rassoc("original")
p ENV.delete(key) { "unused" }
p ENV[key]
p ENV.delete(key) { |missing| missing + ":delete" }
p ENV.fetch(key) { |missing| missing + ":fetch" }
p ENV.fetch(key, "default")
p ENV.fetch(key, 7)
p ENV.fetch(key, nil)
ENV.delete(key)
