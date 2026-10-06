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
end

class Plain
  def inspect = "#<Plain>"
end

vals = [1, nil, :s, 2.5, true, 1..2, Plain.new, [1, 2], {a: 1}, +"str"]
vals.each { |v| try(v, "r") }
vals.each { |v| try(v, [9]) }
vals.each { |v| try(v, {b: 2}) }
vals.each { |v| try(v, nil) }
