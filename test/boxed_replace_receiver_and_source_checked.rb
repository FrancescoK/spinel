# replace on a boxed value: only a String, an Array and a Hash have it, so
# any other receiver raises NoMethodError (with the source as its args),
# and a String's or an Array's source of another kind raises the TypeError
# of its implicit conversion. Each used to answer the receiver unchanged.

def try(v, src)
  p v.replace(src)
rescue NoMethodError => e
  puts "NoMethodError: #{e.message} #{e.args.inspect}"
rescue TypeError => e
  puts "TypeError: #{e.message}"
rescue FrozenError => e
  puts "FrozenError: #{e.message}"
end

class Plain
  def inspect = "#<Plain>"
end

vals = [1, nil, :s, 2.5, true, 1..2, Plain.new, [1, 2], {a: 1}, +"str"]
vals.each { |v| try(v, "r") }
vals.each { |v| try(v, [9]) }
vals.each { |v| try(v, {b: 2}) }
vals.each { |v| try(v, nil) }

# A frozen receiver raises FrozenError before its source is converted (no
# TypeError for the source, no #to_ary call), and a String's source converts
# through #to_str.
class Str; def to_str = "zz"; end
class Ary; def to_ary; puts "to_ary called"; [9]; end; end
k = ARGV.size
fs = [+"ab", 0][k].freeze
fa = [[1, 2], 0][k].freeze
try(fs, 1)
try(fs, Str.new)
try(fa, Ary.new)
u = [+"ab", 0][k]
try(u, Str.new)
