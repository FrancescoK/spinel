# A merged Hash's default proc runs on the merged Hash: a write in it does
# not reach the receiver the merge copied (#8507).
h = Hash.new { |hash, key| hash[key] = 1 }
m = h.merge({b: 2})
m[:a]
p h, m
s = Hash.new { |hash, key| hash[key] = key * 2 }
s["q"] = "r"
t = s.merge({"z" => "y"})
p t["w"], s, t
y = Hash.new { |hash, key| hash[key] = [key] }
y[:k] = [:v]
z = y.merge({})
p z[:n], y, z
