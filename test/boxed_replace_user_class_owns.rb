# The same probes as boxed_replace_receiver_and_source_checked.rb, with a
# class of the program defining replace: the boxed call dispatches on the
# runtime class, and every other value takes the builtin's answer or error.
# Under SPINEL_GC_STRESS=1 one message here was built where an earlier,
# collected exception's message had been, and came out cut to that one's
# length.

def try(v, src)
  p v.replace(src)
rescue NoMethodError => e
  puts "NoMethodError: #{e.message} #{e.args.inspect}"
rescue TypeError => e
  puts "TypeError: #{e.message}"
end

class Own
  def replace(o) = :own
end

class Plain
  def inspect = "#<Plain>"
end

vals = [1, nil, :s, 2.5, true, 1..2, Plain.new, Own.new, [1, 2], {a: 1}, +"str"]
vals.each { |v| try(v, "r") }
vals.each { |v| try(v, [9]) }
vals.each { |v| try(v, {b: 2}) }
vals.each { |v| try(v, nil) }
