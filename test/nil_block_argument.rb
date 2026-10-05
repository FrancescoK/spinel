# `m(&nil)` passes no block: it is the blockless call. The `&nil` stayed a
# block argument and the arms that only ask whether there is a block took
# their block form: `"e".bytes(&nil)` answered the receiver String, and
# sort / split with `&nil` did not build (#7412).
class BytesProbe
  def values
    "é".bytes(&nil)
  end
end
p BytesProbe.new.values
p "ab".chars(&nil)
p "a\nb".lines(&nil)
p "ab".codepoints(&nil)
p [1, 2, 3].map(&nil).class
p [3, 1, 2].sort(&nil)
p [3, 1, 2].max(&nil)
p({a: 1}.to_a(&nil))
p "a b".split(" ", &nil)
p [1, 2, 3].each_slice(2, &nil).to_a
p (1..3).select(&nil).class

def take(v)
  block_given? ? yield(v) : "no block: #{v}"
end
puts take(1, &nil)
puts take(2) { |v| "block: #{v}" }
