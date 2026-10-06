# +, -, |, & and concat on an Array convert a boxed operand that is a
# program object through its #to_ary, as CRuby does; one without #to_ary
# raises "no implicit conversion", and one whose #to_ary answers a
# non-Array raises "can't convert".
class W
  def to_ary = [9]
end
class N; end
class B
  def to_ary = 5
end
def t
  p yield
rescue => e
  puts "#{e.class}: #{e.message}"
end
x = [W.new, 5][0]
t { [1] + x }
t { ["a", 2.5] + x }
t { [1, 2, 9] - x }
t { [1] | x }
t { [9, 1] & x }
t { b = [1]; b.concat(x); b }
t { [1] + [N.new, 5][0] }
t { [1] | [N.new, 5][0] }
t { [1] + [B.new, 5][0] }
t { [1] - [B.new, 5][0] }
t { [1] + [[2], 5][0] }
