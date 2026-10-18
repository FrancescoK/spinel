# The matches of a scan, each read through $~ in the block that sees it:
# `Regexp.last_match` in scan's own block, and in the block of a map or an
# each over `to_enum(:scan, re)`.
RE = /a(\d)/
str = "a1 b a2 a3"

r = []
str.scan(RE) { r << Regexp.last_match.begin(0) }
p r
str.scan(/b|a2/) { r << Regexp.last_match[0] }
p r

p str.to_enum(:scan, RE).map { Regexp.last_match }
p str.to_enum(:scan, RE).map { Regexp.last_match[1].to_i * 10 }
p str.to_enum(:scan, RE).map { |m| [m, Regexp.last_match.begin(0)] }
p str.to_enum(:scan, /\w\d/).collect { |w| "#{w}@#{Regexp.last_match.end(0)}" }
seen = []
p str.to_enum(:scan, RE).each { seen << Regexp.last_match.pre_match.size }
p seen
p "".to_enum(:scan, RE).map { Regexp.last_match }

def words(s) = s
src = words(ARGV.size > 3 ? 7 : "x9 y8")
p src.to_enum(:scan, /[a-z](\d)/).map { Regexp.last_match[1] }
