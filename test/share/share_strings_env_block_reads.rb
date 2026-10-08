# spinel: gc-minor
# A read-only delete block remains usable when another block shares the key.
key = +"SPINEL_SHARE_ENV_READ_BLOCK"
ENV.delete(key)
p ENV.delete(key) { |read_key| read_key + ":read" }
ENV.fetch(key) { |changed_key| changed_key << "!" }
p key
ENV.delete("SPINEL_SHARE_ENV_READ_BLOCK")
ENV.delete(key)
