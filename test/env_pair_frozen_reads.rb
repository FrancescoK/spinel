# spinel: share
# spinel: gc-minor
# assoc keeps its key; rassoc copies a mutable key and keeps its value.
key = +"SPINEL_ENV_PAIR_FROZEN_72B8"
value = +"spinel pair value 72b8"
ENV[key] = value
a = ENV.assoc(key)
p a[0].frozen?, a[1].frozen?
r = ENV.rassoc(value)
p r[0].frozen?, r[1].frozen?
p key.frozen?, value.frozen?
p ENV.assoc("SPINEL_ENV_PAIR_FROZEN_72B8")[0].frozen?
p ENV.rassoc("spinel pair value 72b8")[1].frozen?
count = 0
100.times do
  pair = ENV.assoc(key)
  reverse = ENV.rassoc(value)
  count += 1 if pair[1].frozen? && !reverse[0].frozen?
end
p count
ENV.delete(key)
