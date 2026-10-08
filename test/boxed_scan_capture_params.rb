# A boxed String's capturing scan binds the whole row or destructures it,
# including nil for absent and surplus groups, just like a typed String.
# spinel: gc-minor
# spinel: share
def scan_subject(i) = [+"a1 b", nil][i]

p scan_subject(0).scan(/([a-z])(\d)?/) { |word, digit, extra| p [word, digit, extra] }
p scan_subject(0).scan(/([a-z])(\d)?/) { |row| p row }
scan_subject(0).scan(/([a-z])(\d)?/) { p [$~[0], $~.begin(0)] }
scan_subject(0).scan(/([a-z])(\d)?/) { puts "match" }

# Runtime patterns decide whether the yielded value is a capture Array or
# a whole-match String. A single parameter keeps the Array intact.
def runtime_scan_subject(i) = ["1x 2y 3".dup, nil][i]

rows = []
p runtime_scan_subject(0).scan(Regexp.new("(\\d)(\\w)")) { |a, b| rows << [a, b] }
p rows
runtime_scan_subject(0).scan(Regexp.new("(\\d)(\\w)")) { |m| p m }
runtime_scan_subject(0).scan(Regexp.new("(\\d)(\\w)")) { puts "match" }

pattern = Regexp.new("(\\d)(x)?")
p runtime_scan_subject(0).scan(pattern) { |a, b| p [a, b] }
runtime_scan_subject(0).scan(pattern) { |m| p m }
runtime_scan_subject(0).scan(pattern) { puts "match" }

# A boxed pattern can hold either kind, with or without captures. Exercise
# the same binding on a typed String and preserve nil for surplus params.
[Regexp.new("(\\d)(\\w)"), Regexp.new("(\\d)(x)?"), Regexp.new("\\d"), "1x"].each do |pat|
  p runtime_scan_subject(0).scan(pat) { |a, b, extra| p [a, b, extra] }
  runtime_scan_subject(0).scan(pat) { |m| p m }
  runtime_scan_subject(0).scan(pat) { puts "match" }
  p "1x 2y 3".dup.scan(pat) { |a, b, extra| p [a, b, extra] }
  "1x 2y 3".dup.scan(pat) { |m| p m }
  "1x 2y 3".dup.scan(pat) { puts "match" }
end

"1x 2y 3".dup.scan(Regexp.new("(\\d)(x)?")) { |m| p m }
"1x 2y 3".dup.scan(pattern) { |a, b| p [a, b] }
