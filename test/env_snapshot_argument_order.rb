# spinel: share
# spinel: gc-minor
# Arguments finish left to right before ENV is read or a key is checked.
k = 'SPINEL_ENV_SNAPSHOT_ORDER_8D91'
other = 'SPINEL_ENV_SNAPSHOT_OTHER_8D91'
ENV.delete(k)
ENV.delete(other)
p ENV.values_at((ENV[k] = 'one'; k))
p ENV.assoc((ENV[k] = 'two'; k))
p ENV.rassoc((ENV[k] = 'spinel snapshot 8d91'; 'spinel snapshot 8d91'))
p ENV.slice((ENV[k] = 'three'; k))
p ENV.fetch((ENV[k] = 'four'; k)) { 'missing' }
p ENV.values_at((ENV[k] = 'five'; k), (ENV[k] = 'six'; k))
p ENV.slice(*[(ENV[k] = 'seven'; k), (ENV[other] = 'eight'; other)])
p ENV.values_at(*[(ENV[k] = 'nine'; k), (ENV[other] = 'ten'; other)])
begin
  ENV.values_at("bad\0name", (ENV[k] = 'after NUL'; k))
rescue ArgumentError => e
  p e.message, ENV[k]
end
begin
  ENV.slice("bad\0name", (ENV[k] = 'after slice NUL'; k))
rescue ArgumentError => e
  p e.message, ENV[k]
end
begin
  ENV.values_at(1, (ENV[k] = 'after type error'; k))
rescue TypeError => e
  p e.message, ENV[k]
end
begin
  ENV.values_at((raise 'argument stops call'), (ENV[k] = 'not reached'; k))
rescue RuntimeError => e
  p e.message, ENV[k]
end
p ENV.assoc((ENV[k] = 'allocated'; k + ''))
keys = ["bad\0name"]
begin
  ENV.values_at(*keys, (ENV[k] = 'after splat NUL'; k))
rescue ArgumentError => e
  p e.message, ENV[k]
end
p ENV.fetch((ENV.delete(k); k)) { |name| name + ': missing' }
p ENV.each_with_object((ENV[k] = 'seeded'; [])) { |name, values| values << name[1] if name[0] == k }
seen = ''
ENV.each_with_object((ENV[k] = 'statement'; [])) { |pair, memo| seen = pair[1] if pair[0] == k }
p seen
p ENV.to_h { |name, value| [name, name == k ? value + '!' : value] }[k]
p ENV.select { |name, value| name == k }[k]
p ENV.filter_map { |name, value| value if name == k }
ENV.delete(k)
ENV.delete(other)
