# An endless String range iterates by String#succ, one member at a time: each,
# first(n), take, lazy, step and the other walks stop where the block or the
# count says, rather than materializing the members and raising RangeError.

("a"..).each { |s| break if s == "e"; print s }
puts
p ("a"..).first(3)
p ("x"..).take(4)
p ("a"...).first(2)
p ("a"..).lazy.map(&:upcase).first(2)
("a"..).step(2) { |s| break if s > "g"; print s }
puts
p ("a"..).step(2).first(3), (("a"..) % 3).first(2)
p ("a"..).each_slice(2).first(2)
p ("y"..).each_cons(2).first(2)
p ("a"..).each_with_index.first(2)
p ("a"..).find_index("c")
p ("a"..).take_while { |s| s < "c" }
p ("a"..).find { |s| s > "c" }
e = ("a"..).each
p e.next, e.next

def count_z(n)
  out = []
  ("a"..).each do |s|
    break if s.size > n
    out << s if s.end_with?("z")
  end
  out.size
end
p count_z(2)
p(("a"..).each { |s| break s * 2 if s == "c" })
p ("a"..).first
