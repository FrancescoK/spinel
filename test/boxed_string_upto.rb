# upto on a boxed receiver that is a String: String#upto walks the
# successor sequence (to the limit, or before it when exclusive), with a
# block or as an Enumerator, where the Integer face raised NoMethodError.
# An Integer receiver beside it counts as before; another value raises
# NoMethodError, an Integer given a String limit or the exclusive flag
# raises CRuby's ArgumentError, and a String given a numeric limit its
# TypeError. A break in the block answers the break's value.

def t
  p yield
rescue NoMethodError => e
  puts "#{e.message} #{e.args.inspect}"
rescue => e
  puts "#{e.class}: #{e.message}"
end

k = ARGV.size
[["a", "c"], ["9", "11"], [1, 3], [1, "c"], [nil, "c"], [:s, "u"]].each do |v, w|
  n = [v, 0][k]
  lim = [w, 0][k]
  t { r = []; n.upto(lim) { |x| r << x }; r }
  t { r = []; n.upto("c") { |x| r << x }; r }
  t { n.upto(lim).to_a }
  t { n.upto(lim, true).to_a }
  t { r = []; n.upto(lim, true) { |x| r << x }; r }
  t { n.upto(lim).map { |x| x * 2 } }
  t { s = 0; n.upto(lim) { |x| next if x == lim; s += 1 }; s }
end
t { r = []; [5, 0][k].upto(7) { |x| r << x }; r }

# a numeric limit on a boxed String is String#upto's TypeError; an
# Integer receiver counts as before
[["a", 0], [5, 0]].each do |v, _|
  n = [v, 0][k]
  t { r = []; n.upto(7) { |x| r << x }; r }
  t { n.upto(7).to_a }
  t { r = []; n.upto(7.5) { |x| r << x }; r }
end

# a block that breaks: the break's value is the call's
t { ["a", 1][k].upto("e") { |x| break x * 2 if x == "c" } }
t { ["a", 1][k].upto("e") { |x| break if x == "b" } }
t { s = 0; ["a", 1][k].upto("e") { |x| s += 1; break if x == "d" }; s }
t { [1, "a"][k].upto([5, 0][k]) { |x| break x * 10 if x == 3 } }
