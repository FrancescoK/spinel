# A mutator called straight on a `yield` whose block gives a different kind
# of Array (or a String) at each call site. The value is boxed and the call
# goes to the kind the box holds. `reverse!` re-entered the boxed call
# without end, so the compiler never finished; `sort!`, `rotate!`, `uniq!`,
# `compact!`, `select!` and `shuffle!` answered ill-typed C.
def rev(v) = yield(v).reverse!
def srt(v) = yield(v).sort!
def rot(v) = yield(v).rotate!
def uni(v) = yield(v).uniq!
def cmp(v) = yield(v).compact!
def sel(v) = yield(v).select! { |x| x }
def shuf(v) = yield(v).shuffle!.size
def twice(v)
  a = yield(v).reverse!
  b = yield(v).reverse!
  [a, b]
end

p rev([1, 2, 3]) { |q| q }
p rev(["a", "b"]) { |q| q }
p rev(+"abc") { |q| q }
p rev([1.5, 2.5]) { |q| q }
p rev([]) { |q| q }
p srt([3, 1, 2]) { |q| q }
p srt(["b", "a"]) { |q| q }
p srt([2.5, 1.5]) { |q| q }
p rot([1, 2, 3]) { |q| q }
p rot(["a", "b", "c"]) { |q| q }
p uni([1, 1, 2]) { |q| q }
p uni(["a", "a"]) { |q| q }
p uni([1, 2]) { |q| q }
p cmp([1, nil, 2]) { |q| q }
p cmp(["a", nil]) { |q| q }
p cmp([1, 2]) { |q| q }
p sel([1, nil, 2]) { |q| q }
p sel(["a", nil]) { |q| q }
p shuf([1, 2, 3]) { |q| q }
p shuf(["a", "b"]) { |q| q }
p twice([1, 2, 3]) { |q| q }
p twice(["a", "b"]) { |q| q }
x = [4, 5, 6]
p rev(x) { |q| q }
p x
y = ["p", "q"]
p rev(y) { |q| q }
p y
