# Array#+ - | & concat <=> with an object whose class answers to_ary with an
# Array convert it through to_ary, as CRuby does; a nil operand is
# TypeError, as for any non-Array.
class W
  def to_ary = [9]
end
def t
  p yield
rescue => e
  puts "#{e.class}: #{e.message}"
end
w = W.new
t { [1] + w }
t { [1, 9] - w }
t { [1] | w }
t { [1, 9] & w }
t { [1].concat(w) }
t { [1] <=> w }
t { [1].zip(w) }
t { %w[a] + w }
def pick(f) = f ? W.new : nil
t { [1] + pick(true) }
t { [1] + pick(false) }
x = [1]
x.concat(W.new)
p x
