# spinel: gc-stress
# A push or concat of another kind onto a typed Array that a builtin
# call built and froze in the same chain raises FrozenError, after
# every argument has run.

def try
  yield
rescue FrozenError => e
  puts "FrozenError: #{e.message}"
end

try { "a b".split.freeze.concat([1]) }
try { p("a b".split.freeze.concat([1], [2.5])) }
try { "a b".split.freeze << 1 }
try { "a b".split.freeze.push(1, p(:arg)) }
try { "a b".split.freeze.concat([1], p([:arg])) }
try { "a b".split.freeze.concat([]) }
try { "a b".split.freeze.concat(*[[1]]) }
try { "a b".scan(/a/).freeze.concat([1.5]) }
try { [1, 2].map { _1 }.freeze.concat(["s"]) }
try { [1, 2].map { _1 }.freeze << "s" }

# not frozen: the general Array takes the other kind
p "a b".split.concat([1])
p "a b".split.dup.concat([1, :x])
p("a b".split << 1)
p "a b".split.push(1, :x)
