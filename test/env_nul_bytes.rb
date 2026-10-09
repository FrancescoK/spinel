# An ENV name or value with an embedded NUL cannot reach the C environment:
# CRuby raises ArgumentError naming which one, before anything is stored,
# where a C string would have been cut short at the NUL. The reads that
# take a name check it too; the reads that take a value only compare.
def try(label)
  print label, ": "
  p yield
rescue ArgumentError => e
  puts e.message
end
pre = "SPINEL_ENV_NUL_"
name = pre + "A"
bad_name = "#{pre}B\0C"
bad_value = "v\0w"
boxed = [bad_name, 1][0]
try("[]= name") { ENV[bad_name] = "x" }
try("[]= value") { ENV[name] = bad_value }
try("[]= boxed value") { ENV[name] = [bad_value, 1][0] }
try("[]= nil") { ENV[bad_name] = nil }
try("store name") { ENV.store(bad_name, "x") }
try("store value") { ENV.store(name, bad_value) }
try("[] boxed name") { ENV[boxed] }
p ENV.key?(pre + "B")
try("[]") { ENV[bad_name] }
try("fetch") { ENV.fetch(bad_name) }
try("fetch default") { ENV.fetch(bad_name, (print "default "; "d")) }
try("fetch block") { ENV.fetch(bad_name) { |k| k } }
try("key?") { ENV.key?(bad_name) }
try("include?") { ENV.include?(bad_name) }
try("has_key?") { ENV.has_key?(bad_name) }
try("member?") { ENV.member?(bad_name) }
try("delete") { ENV.delete(bad_name) }
try("assoc") { ENV.assoc(bad_name) }
try("values_at") { ENV.values_at(name, bad_name) }
try("values_at splat") { ENV.values_at(*[name, bad_name]) }
try("slice") { ENV.slice(bad_name) }
try("slice splat") { ENV.slice(*[bad_name]) }
try("key") { ENV.key(bad_value) }
try("rassoc") { ENV.rassoc(bad_value) }
try("except") { ENV.except(bad_name).key?(name) }
try("update name") { ENV.update(name => "1", bad_name => "2") }
p ENV[name]
try("update value") { ENV.merge!(pre + "C" => bad_value) }
try("update block") { ENV.update(name => "x") { |k, old, new| old + "\0" } }
p ENV[name]
try("update boxed") { ENV.update({ name => "3", 1 => 2 }.select { |k, v| k == name }.merge(bad_name => nil)) }
p ENV[name]
ENV[pre + "KEEP"] = "keep"
try("replace") { ENV.replace(ENV.to_h.merge(pre + "D" => "d", bad_name => "e")) }
p [ENV[pre + "D"], ENV[pre + "KEEP"]]
try("replace value") { ENV.replace(ENV.to_h.merge(pre + "E" => "e", pre + "F" => bad_value)) }
p [ENV[pre + "E"], ENV[pre + "F"], ENV[pre + "KEEP"]]
p ENV.keys.select { |k| k.start_with?(pre) }.sort
%w[A B C D E F KEEP].each { |s| ENV.delete(pre + s) }
p ENV.keys.select { |k| k.start_with?(pre) }
