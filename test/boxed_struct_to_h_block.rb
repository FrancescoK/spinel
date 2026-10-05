# to_h with a block on a Struct or Data value held in a mixed Array (a
# boxed receiver) yields its [member, value] pairs, as Struct#to_h does,
# where it yielded the values; Arrays, Hashes and Ranges keep theirs.
def t
  p yield
rescue => e
  puts "#{e.class}: #{e.message}"
end
S = Struct.new(:a, :b)
D = Data.define(:x, :y)
t { [S.new(1, 2), 5][0].to_h { |k, v| [k, v * 2] } }
t { [S.new(1, 2), 5][0].to_h { [_2, _1] } }
t { [D.new(x: 1, y: 2), 5][0].to_h { |k, v| [k.to_s, v] } }
t { [[[1, 2], [3, 4]], 5][0].to_h { |a, b| [b, a] } }
t { [{a: 1}, 5][0].to_h { |k, v| [v, k] } }
t { [(1..3), 5][0].to_h { [_1, _1 * _1] } }
t { [S.new(1, 2), 5][0].to_h }
