# spinel: share
# spinel: gc-minor
# Mutators expose frozen environment copies without freezing supplied values.
key = "SPINEL_ENV_FROZEN_MUTATORS_72B8"
ENV[key] = "old"
ENV.update({key => +"new"}) do |k, old, value|
  p k.frozen?, old.frozen?, value.frozen?
  value
end
ENV.delete_if do |k, value|
  p k.frozen?, value.frozen? if k == key
  k == key
end
ENV.replace({key => "shift"})
pair = ENV.shift
p pair[0].frozen?, pair[1].frozen?
p ENV[key]
ENV.delete(key)
