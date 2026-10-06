# A String Range's min / max with a comparator block walk its members and
# compare them with the block, as Enumerable's do; the endpoint readers
# answered as though there were no block. Without a block they keep
# answering off the endpoints.

def t(s)
  r = yield
  puts "#{s}: #{r.inspect}"
rescue StandardError => e
  puts "#{s}: #{e.class}: #{e.message}"
end

r = "a".."e"
t("min rev") { r.min { |a, b| b <=> a } }
t("max rev") { r.max { |a, b| b <=> a } }
t("min by length") { ("a".."zz").min { |a, b| b.length <=> a.length } }
t("max by length") { ("x".."ab").max { |a, b| a.length <=> b.length } }
t("excl") { ("a"..."e").max { |a, b| a <=> b } }
t("empty") { ("e".."a").min { |a, b| a <=> b } }
t("plain") { [r.min, r.max] }
t("literal") { ("b".."d").max { |a, b| b <=> a } }
m = ["a".."e", 3][0]
p m.min { |a, b| b <=> a }
p m.max { |a, b| b <=> a }
