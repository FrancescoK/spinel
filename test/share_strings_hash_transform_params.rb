# Transform blocks bind their parameter in the representation of its slot.
# Destructuring the same names in another block makes sharing visible here.
# spinel: gc-minor
def make_hash
  h = {}
  3.times { |i| h["k#{i}"] = "v#{i}" }
  h
end

def churn
  100.times { "q" * 64 }
end

r = make_hash.each_with_object([]) { |(k, v), acc| acc << k; acc << v }
p r
r = make_hash.transform_keys { |k| churn; k.upcase }
p r
r = make_hash.transform_values { |v| churn; v.upcase }
p r
r = make_hash.transform_keys { |k| churn; next k.upcase }
p r
r = make_hash.transform_values { |v| churn; next v.upcase }
p r
r = make_hash.transform_keys { |k| churn; k }
p r
r = make_hash.transform_values { |v| churn; v }
p r
r = make_hash.transform_keys { |k| churn; k.frozen? ? k : "unfrozen" }
p r
p({a: 1, b: 2}.transform_keys { |key| key.to_s })
p({a: 1, b: 2}.transform_values { |value| value + 1 })
