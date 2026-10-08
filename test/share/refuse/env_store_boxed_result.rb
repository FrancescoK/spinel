# A boxed value may still hold plain bytes; its returned alias needs a handle.
class EnvStringValue
  def value = +"ab"
end
class EnvIntegerValue
  def value = 7
end
objects = [EnvStringValue.new, EnvIntegerValue.new]
value = objects[0].value
result = ENV.store("SPINEL_SHARE_ENV_BOXED_STORE", value)
result << "!"
p value, result, ENV["SPINEL_SHARE_ENV_BOXED_STORE"]
ENV.delete("SPINEL_SHARE_ENV_BOXED_STORE")
