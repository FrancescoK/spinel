# The fold and collect emitters copy their receiver into a C temporary and then
# read that temporary again on every turn -- as the loop bound, and as the
# container the entry comes out of -- while the block between two turns
# allocates. Every arm here hands one of them a receiver no Ruby name holds (a
# method's answer), and every block allocates before it looks at what it was
# given, so an arm whose receiver was collected mid-walk reports a short count
# rather than passing quietly. The local-receiver arms are the control: those
# were always safe, because the local is a root.
# spinel: share
ENTRIES = 40
CHURN = 100

def churn
  CHURN.times { "q" * 64 }
end

def make_hash
  h = {}
  (1..ENTRIES).each { |i| h["k#{i}"] = "v#{i}" }
  h
end

def make_array
  (1..ENTRIES).map { |i| "a#{i}" }
end

# --- Hash#map / #collect, #select / #filter / #find_all, #reject ---

n = 0
r = make_hash.map { |k, _v| churn; n += 1; k }
puts "hash map n=#{n} out=#{r.size}"

n = 0
r = make_hash.collect { |k, _v| churn; n += 1; k }
puts "hash collect n=#{n} out=#{r.size}"

n = 0
r = make_hash.select { |_k, _v| churn; n += 1; true }
puts "hash select n=#{n} out=#{r.size}"

n = 0
r = make_hash.filter { |_k, _v| churn; n += 1; true }
puts "hash filter n=#{n} out=#{r.size}"

n = 0
r = make_hash.reject { |_k, _v| churn; n += 1; false }
puts "hash reject n=#{n} out=#{r.size}"

h = make_hash
n = 0
r = h.select { |_k, _v| churn; n += 1; true }
puts "hash select local n=#{n} out=#{r.size}"

# --- Hash#transform_keys / #transform_values ---

n = 0
r = make_hash.transform_keys { |k| churn; n += 1; k.upcase }
puts "hash transform_keys n=#{n} out=#{r.size} first=#{r.keys.first}"

n = 0
r = make_hash.transform_values { |v| churn; n += 1; v.upcase }
puts "hash transform_values n=#{n} out=#{r.size} first=#{r.values.first}"

# --- Array#min_by / #max_by / #minmax_by: a short walk answers from the
#     prefix it managed to read, so the answer changes, not just the count ---

n = 0
r = make_array.min_by { |x| churn; n += 1; x }
puts "array min_by n=#{n} out=#{r}"

n = 0
r = make_array.max_by { |x| churn; n += 1; x }
puts "array max_by n=#{n} out=#{r}"

n = 0
r = make_array.minmax_by { |x| churn; n += 1; x }
puts "array minmax_by n=#{n} out=#{r.inspect}"

# --- Array#group_by ---

n = 0
r = make_array.group_by { |x| churn; n += 1; x.size }
puts "array group_by n=#{n} out=#{r.values.map(&:size).sum}"

# --- Array#grep / #grep_v with a block ---

n = 0
r = make_array.grep(/a/) { |x| churn; n += 1; x }
puts "array grep n=#{n} out=#{r.size}"

n = 0
r = make_array.grep_v(/zz/) { |x| churn; n += 1; x }
puts "array grep_v n=#{n} out=#{r.size}"

# --- #each_with_object, both receivers ---

n = 0
r = make_hash.each_with_object([]) { |(k, _v), acc| churn; n += 1; acc << k }
puts "hash each_with_object n=#{n} out=#{r.size}"

n = 0
r = make_array.each_with_object([]) { |x, acc| churn; n += 1; acc << x }
puts "array each_with_object n=#{n} out=#{r.size}"

a = make_array
n = 0
r = a.each_with_object([]) { |x, acc| churn; n += 1; acc << x }
puts "array each_with_object local n=#{n} out=#{r.size}"

# --- Array#partition ---

n = 0
r = make_array.partition { |x| churn; n += 1; x.size.even? }
puts "array partition n=#{n} out=#{r[0].size + r[1].size}"
