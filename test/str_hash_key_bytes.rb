# A String key is hashed and compared by all its bytes: past an embedded NUL,
# and the same whether the String is a literal, a slice, a copy, frozen,
# interpolated or a Symbol's name.
lens = [0, 1, 7, 8, 15, 16, 17, 23, 24, 25, 31, 32, 33, 64, 100]
base = "abcdefghijklmnopqrstuvwxyz0123456789" * 3
h = {}
lens.each { |n| h[base[0, n]] = n }
lens.each do |n|
  k = base[0, n]
  forms = [k, k.dup, +k, k.dup.freeze, (k + "x").chop, k.b.force_encoding("UTF-8"), k.to_sym.to_s, "#{k}", [k].join]
  puts "#{n}: #{forms.map { |v| h[v] == n && v.hash == k.hash }.uniq.inspect}"
end
p lens.map { |n| base[0, n].hash }.uniq.size

# literal keys, looked up with Strings built at run time
h2 = { "customer_account_17_field" => 1, "/var/log/application/services/billing/7/events.log" => 2,
       "exactly_16_bytes" => 3, "seventeen_bytes!!" => 4, "id" => 5 }
p h2["customer_account_" + "17_field"], h2["/var/log/application/services/billing/#{7}/events.log"],
  h2["exactly_" + "16_bytes"], h2["seventeen" + "_bytes!!"], h2["i" + "d"], h2["i" + "d" + "x"], h2["seventeen_bytes!"]

# an embedded NUL, short and long
nul = { "a\0b" => 1, "a\0c" => 2, "a" => 3 }
p nul.size, nul["a\0b"], nul["a\0c"], nul["a"], nul["a\0"], "a\0b".hash == "a\0c".hash
long1 = "x" * 20 + "\0" + "y"
long2 = "x" * 20 + "\0" + "z"
lh = { long1 => 1, long2 => 2 }
p lh.size, lh["x" * 20 + "\0y"], lh["x" * 20], long1.hash == long2.hash
packed = (0...300).map { |i| [0, i].pack("CN") }
ph = {}
packed.each_with_index { |k, i| ph[k] = i }
p ph.size, packed.sum { |k| ph[k] }

# BINARY and UTF-8 keys of the same bytes: one key when the bytes are ASCII
enc = { "abc" => 1, "café" => 2, "abc" * 10 => 3, "café" * 5 => 4 }
p enc["abc".b], enc["caf\xC3\xA9".b], enc[("abc" * 10).b], enc[("caf\xC3\xA9" * 5).b]
p "caf\xC3\xA9".b.hash == "café".hash, ("caf\xC3\xA9" * 5).b.hash == ("café" * 5).hash

# a key the program builds and then changes
k = +"mutable_key_longer_than_16"
mh = { k.dup => 1 }
p mh[k]
k << "!"
p mh[k], mh[k.chop]
