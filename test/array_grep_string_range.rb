b = ["abc", 1]
p b.grep("a".."z")
p b.any?(/b/)
s = +"ab"
s << "c"
a = [s, 1]
p a.grep("a".."z")

values = ["a", "abc", "z", "zz", 1, nil, s]
p values.grep("a".."z")
p values.grep("a"..."z")
p values.grep_v("a".."z")
p values.any?("a".."z")
p values.grep("a".."z") { |v| v.upcase }

# the same comparison behind every === of a String range against a boxed value
def covered?(r, x) = r === x
p covered?("a".."c", values[1])
p values.count { |v| ("a".."z") === v }
p values.select { |v| ("a".."z") === v }
p values.filter_map { |v| v.to_s * 2 if ("a".."z") === v }
