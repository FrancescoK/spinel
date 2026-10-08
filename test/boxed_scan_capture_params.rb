# A boxed String's capturing scan binds the whole row or destructures it,
# including nil for absent and surplus groups, just like a typed String.
def scan_subject(i) = [+"a1 b", nil][i]

p scan_subject(0).scan(/([a-z])(\d)?/) { |word, digit, extra| p [word, digit, extra] }
p scan_subject(0).scan(/([a-z])(\d)?/) { |row| p row }
scan_subject(0).scan(/([a-z])(\d)?/) { p [$~[0], $~.begin(0)] }
scan_subject(0).scan(/([a-z])(\d)?/) { puts "match" }
