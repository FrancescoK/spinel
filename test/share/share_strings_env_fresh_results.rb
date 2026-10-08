# spinel: gc-minor
# A missing-key block's new String is independent of the supplied key.
key = +"SPINEL_ENV_FRESH_RESULTS"
ENV.delete(key)
value = ENV.delete(key) { |missing| missing + "x" }
value << "y"
p key, value
literal = ENV.delete("SPINEL_ENV_FRESH_RESULTS") { |missing| missing + "x" }
literal << "y"
p literal
fetched = ENV.fetch(key) { |missing| missing + "x" }
fetched << "y"
p key, fetched

# A default with no further read may be handed on and mutated.
default = +"dd"
result = ENV.fetch("SPINEL_ENV_FRESH_RESULTS", default)
result << "!"
p result

# A plain value read cannot change a mutable key while it is evaluated.
stored = +"v"
answer = ENV.store(key, stored)
key << "Z"
answer << "!"
p key, stored, ENV["SPINEL_ENV_FRESH_RESULTS"]
ENV.delete("SPINEL_ENV_FRESH_RESULTS")
