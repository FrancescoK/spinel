# A Range whose ends read elements of a container of boxed values: a mixed
# Array or a Hash of them. Under --int-overflow=promote such a Range was an
# Integer Range, as every Range of boxed ends is there, and a String end
# raised ArgumentError ("bad value for range") where CRuby walks the
# String Range. The ends are what the values at run time are, in every
# mode.
arr = [:x, "b", "e"]
p((arr[1]..arr[2]).to_a)
p((arr[1]...arr[2]).to_a)
p((arr[1]..arr[2]).include?("c"))

def via_param(a) = (a[1]..a[2]).to_a
p via_param(arr)

words = ["b", 7, "d"]
p((words.first..words.last).to_a)
p((words.fetch(0)..words.fetch(2)).count)

h = {lo: "x", hi: "z", n: 1}
p((h[:lo]..h[:hi]).to_a)
p((h.fetch(:lo)..h.fetch(:hi)).map(&:upcase))

nested = {r: ["m", "o"], k: 1}
p((nested.dig(:r, 0)..nested.dig(:r, 1)).to_a)

# Integer and Float elements of the same kind of container
nums = [1, "x", 5]
p((nums[0]..nums[2]).to_a)
p((nums[0]..nums[2]).sum)
mix = [0.5, "y", 2]
p((mix[0]..mix[2]).include?(1.5))
