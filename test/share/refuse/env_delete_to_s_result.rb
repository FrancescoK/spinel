# String#to_s still returns the key; the block result may not copy it.
key = +"SPINEL_ENV_DELETE_TO_S"
ENV.delete(key)
result = ENV.delete(key) { |missing| missing.to_s }
result << "!"
p key, result
