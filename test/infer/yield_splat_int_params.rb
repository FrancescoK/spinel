# `yield(*xs)` of an Integer array into `|a, b|` binds two sp_int, the one
# the array may be too short for marked nullable, so only boxing it tests
# for the sentinel. An array literal's values are sure to be there, so its
# parameters stay unmarked. A yielding method reached before the array is
# typed waits for it rather than boxing the parameters for good.
def pair(xs) = yield(*xs)
def later(n) = [n, n + 1]
def chain(n) = pair(later(n)) { |a, b| a * b }
def lit(i) = yield(*[i, i + 1])
t = 0
pair([3, 4]) { |e, f| t += e * f }
p t
p chain(5)
pair([6]) { |g, h| p [h, :s] }
lit(2) { |c, d| p [d, :s] }
