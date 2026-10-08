# The key object stays live while the value expression can mutate it.
def env_mutate_key(key, value)
  key << "_CHANGED"
  GC.start
  value
end
key = +"SPINEL_SHARE_ENV_KEY_OPERAND"
value = +"ab"
result = ENV.store(key, env_mutate_key(key, value))
result << "!"
p key, value, result, ENV[key]
ENV.delete(key)
ENV.delete("SPINEL_SHARE_ENV_KEY_OPERAND")
