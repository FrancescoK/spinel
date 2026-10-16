# A builtin that reads a boxed String through its bytes still hands back
# the String itself: putc answers its argument, and a merged Hash's
# default proc gets the key it was asked for. Under --share-strings the
# box holds the String's handle, and a mutation through the answer or
# the proc's key reaches the caller's String.
s = +"ab"
v = [s, 1].first
f = File.open(File::NULL, "w")
r = f.putc(v)
p r.equal?(s)
r << "!"
p s
f.close

seen = nil
h = Hash.new { |_hash, k| seen = k; k.size }
h["x"] = 1
k = +"key"
m = h.merge({ 1 => 2 })
p m[[k, 1].first], seen.equal?(k)
seen << "!"
p k
