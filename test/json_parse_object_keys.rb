# JSON.parse makes each object key once, frozen, as the Hash stores it,
# and inside an array shares one key among the objects that repeat it, as
# CRuby's parser does (`equal?`): a per-parse cache of at most 63 keys of
# up to 55 bytes that begin with a letter. Every key reads as CRuby's:
# more distinct keys than the cache holds, keys beginning with `_` or a
# digit, an escaped key, a duplicate key, a long key, a key outside any
# array, a shared key that refuses to change, and a key added to one
# parsed Hash only.
require "json"
require "ostruct"

text = '{"top": [' + (0...200).map { |i|
  %({"id": #{i}, "name": "n#{i}", "k#{i % 80}": #{i}, "_u": 1, "1": 2, "a\\u0062": 3, "a": 1, "a": 2, "#{"long" * 15}": 0})
}.join(", ") + '], "solo": {"x": 1}}'
doc = JSON.parse(text)
rows = doc["top"]
p rows.size, rows[5].keys, rows[199]["k39"], rows[7]["ab"], rows[7]["a"]
p rows.map { |r| r["id"] }.sum, rows[0].keys.size, doc["solo"]
k0 = rows[0].keys.first
p k0.frozen?, k0, k0.equal?(rows[1].keys.first)
begin
  k0 << "x"
rescue => e
  p e.class
end
h = rows[3]
h["new"] = 9
p h.size, h["new"], rows[4].key?("new")
p rows[150]["name"], rows[150].keys.first

pairs = '[{"name": "a", "size": 2}, {"name": "b", "size": 3}]'
s = JSON.parse(pairs, symbolize_names: true)
p s, s[1][:name]
o = JSON.parse(pairs, object_class: OpenStruct)
p o.map(&:name)

# a key the Hash does not keep -- an earlier key of the same bytes was
# written with an escape -- is still the cache's to hand out: it has to stay
# alive for the objects that follow
dups = '[{"a\\u0062": 1, "ab": 2}, ' + (1..200).map { |i| %({"ab": #{i}, "w": [#{i}, "v#{i}"]}) }.join(", ") + "]"
d = JSON.parse(dups)
p d[0], d[1], d[200], d[200].keys.first.frozen?
p d.sum { |h| h["ab"] }
ds = JSON.parse(dups, symbolize_names: true)
p ds[0], ds[200]
