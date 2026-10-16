b = "a\xffb\xffc".b
p b.scan(/[^\xff]/n).map(&:encoding).uniq
p b.scan("\xff".b).map(&:encoding).uniq
p b.scan(/(.)(\xff)/n).flatten.map(&:encoding).uniq
r = []
b.scan(/[a-c]/n) { |m| r << m.encoding }
p r.uniq
x = ["a\xffb".b, 1][0]
p x.scan(/[^\xff]/n).map(&:encoding).uniq

u = "a\xE3\x81\x82\xffc".b
p u.scan("").size, u.scan("").map(&:encoding).uniq
p u.gsub(/a/n, "z").encoding, u.sub(/a/n, "z").encoding, u.sub(/q/n, "z").encoding
p u.gsub(/[ac]/n) { |m| m.upcase }.encoding
p u.gsub(/[ac]/n, "a" => "1", "c" => "2").encoding
p u.sub(/[ac]/n, "a" => "1").encoding

t = "aéb"
p t.scan(/./).map(&:encoding).uniq, t.gsub(/a/, "z").encoding, t.scan("").size
