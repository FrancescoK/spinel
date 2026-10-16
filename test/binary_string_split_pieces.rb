b = "a\xffb\xffc".b
p b.split("\xff".b).map(&:encoding).uniq
p b.split("\xff".b, 2).map(&:encoding).uniq
p "a b  c".b.split.map(&:encoding).uniq
p "a,b,c".b.split(/,/).map(&:encoding).uniq
r = []
"x\xffy".b.split("\xff".b) { |s| r << s.encoding }
p r.uniq
p "abc".b.chars.map(&:encoding).uniq
x = [1, "q\xffz".b][1]
p x.split("\xff".b).map(&:encoding).uniq
p "\xE3\x81\x82".b.split("")
p "\xE3\x81\x82".b.split("", 2)
p "\xE3\x81\x82".b.split(//)
p "ab".b.split("", -1).last.encoding
p "a,b".split(",").map(&:encoding).uniq
p "\xE3\x81\x82".split("")
