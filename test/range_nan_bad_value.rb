# A Range with a NaN bound and another bound to compare it with raises
# ArgumentError, as CRuby does; a beginless or endless one with a NaN end
# is kept.
def t
  p yield
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end
n = Float::NAN
t { Float::NAN..1.0 }
t { 1.0..n }
t { 1..n }
t { n..n }
t { n...1.0 }
t { (..n) }
t { (n..) }
t { Range.new(n, 1.0) }
t { (n..1.0).cover?(0.5) }
t { (1.0..2.0) }
