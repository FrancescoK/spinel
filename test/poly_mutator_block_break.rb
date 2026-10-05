# A self-answering mutator (delete_if, keep_if, sort!, sort_by!, merge!,
# update) on a boxed or nilable receiver, given a block that breaks: when
# no break is taken the call answers the receiver, written back; a break
# answers its value. The break made the call's inferred value poly while
# the arm's text answered the typed receiver, and the C did not build.
def run(k)
  a = [nil, [1.5, 2.5, 3.5]][k]
  p a.delete_if { |v| break :cut if v > 9; v > 2 }
  p a
  p a.keep_if { |v| break :kept if v > 1; true }
  p a
  b = [[3, 1, 2], nil][1 - k]
  p b.sort! { |x, y| break :sorted if x == 99; y <=> x }
  p b.sort_by! { |x| break :by if x > 9; x }
  p b
  h = [nil, {"a" => 1, "b" => 2}][k]
  p h.delete_if { |key, v| break :hd if v > 9; v > 1 }
  p h.keep_if { |key, v| break :hk if key == "a"; true }
  p h
  g = k == 1 ? {"x" => 1} : nil
  p g.merge! { |key, o, n| break :m if o > 9; n }
  p g.update { |key, o, n| break :u if o > 9; n }
  p g
end
run(ARGV.size + 1)
