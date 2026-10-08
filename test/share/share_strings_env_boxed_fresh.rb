# spinel: gc-minor
# Both dispatch arms return their own values. Boxing does not create an alias.
class EnvFreshString
  def value = +"ab"
end
class EnvFreshInteger
  def value = 7
end
objects = [EnvFreshString.new, EnvFreshInteger.new]
result = ENV.store("SPINEL_ENV_BOXED_FRESH", objects[0].value)
result << "!"
p result
value = objects[0].value
other = ENV.store("SPINEL_ENV_BOXED_FRESH", value)
other << "?"
p other
ENV.delete("SPINEL_ENV_BOXED_FRESH")
