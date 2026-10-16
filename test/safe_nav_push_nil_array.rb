# A safe-navigation push (or another mutator that appends) on an Array or a
# Hash that is nil skips the call and its arguments, as on any receiver: nil
# is the answer, nothing is evaluated, nothing raises.
def mk(f, v) = f ? v : nil

log = []
[
  [[1, 2], 3],
  [[1.5, 2.5], 3.5],
  [%w[a b], "c"],
  [[[1], [2]], [3]],
  [[1, "a"], 2],
].each do |arr, el|
  n = mk(false, arr)
  n&.push((log << 1; el))
  n&.<<((log << 2; el))
  n&.unshift((log << 3; el))
  n&.concat((log << 4; [el]))
  n&.[]=(0, (log << 5; el))
  n&.size
  n&.clear
  v = n&.push((log << 6; el))
  r = mk(true, arr.dup)
  r&.push((log << 7; el))
  r&.<<((log << 8; el))
  p n, v, r, log
  log.clear
end

h = mk(false, { a: 1 })
h&.store(:b, (log << 1; 2))
h&.[]=(:c, (log << 2; 3))
g = mk(true, { a: 1 })
g&.store(:b, (log << 3; 2))
p h, g, log

# two or more arguments with effects: none runs for a nil receiver
$eff = []

def ei(n)
  $eff << n
  n
end

def es(s)
  $eff << s
  +s
end

x = mk(false, [1, 2])
x&.insert(ei(0), ei(5))
x&.[]=(ei(6), ei(7))
x&.push(ei(8), ei(9))
x&.concat([ei(11)], [ei(12)])
h = mk(false, { 1 => 2 })
h&.store(ei(1), ei(2))
h&.[]=(ei(3), ei(4))
y = mk(false, [+"t"])
y&.push(+"a", es("1"))
y&.[]=(ei(0), es("2"))
y&.insert(ei(1), es("3"), es("4"))
p x, h, y, $eff
r = mk(true, [1, 2])
r&.insert(ei(0), ei(5))
r&.push(ei(8), ei(9))
g = mk(true, { 1 => 2 })
g&.store(ei(1), ei(2))
p r, g, $eff
