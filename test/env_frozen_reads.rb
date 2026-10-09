# spinel: share
# spinel: gc-minor
# spinel: gc-stress
# Strings copied out of ENV are frozen; supplied fallbacks keep their state.
key = "SPINEL_ENV_FROZEN_READS_72B8"
ENV[key] = "spinel frozen value 72b8"
p ENV[key].frozen?
p ENV.fetch(key).frozen?
p ENV.fetch(key, 8).frozen?
p ENV.fetch(key) { 8 }.frozen?
p ENV.to_h[key].frozen?
p ENV.to_hash[key].frozen?
p ENV.keys.find { |k| k == key }.frozen?
p ENV.values_at(key)[0].frozen?
p ENV.key("spinel frozen value 72b8").frozen?
ENV.each { |k, v| p k.frozen?, v.frozen? if k == key }
ENV.each_pair { |k, v| p k.frozen?, v.frozen? if k == key }
ENV.each_key { |k| p k.frozen? if k == key }
ENV.each_value { |v| p v.frozen? if v == "spinel frozen value 72b8" }
p ENV.select { |k, v| k == key }[key].frozen?
p ENV.filter_map { |k, v| v if k == key }[0].frozen?
p ENV.map { |k, v| v if k == key }.compact[0].frozen?
p ENV.reject { |k, v| k != key }[key].frozen?
p ENV.slice(key)[key].frozen?
begin
  ENV[key] << "!"
rescue FrozenError
  puts "frozen append"
end
p ENV.delete(key).frozen?
p ENV.fetch(key, +"default").frozen?
p ENV.fetch(key) { +"block" }.frozen?
p ENV.delete(key) { +"block" }.frozen?
ENV.delete(key)
