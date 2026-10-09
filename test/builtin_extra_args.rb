def bx(v) = [v, 1, "s", nil, :a, 2.0, [1], {b: 1}][$i]
$i = 0
$log = []
def note(x) = ($log << x; x)

def try
  r = yield
  p r
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end

try { "ab".size(foo: 1) }
try { "ab".reverse(foo: 1) }
try { "ab".include?("a", foo: 1) }
try { [1, 2, 3].size(foo: 1) }
try { [1, 2, 3].take(1, foo: 1) }
try { {a: 1}.key?(:a, foo: 1) }
try { {a: 1}.keys(foo: 1) }
try { 7.abs(foo: 1) }
try { 7.gcd(3, foo: 1) }

try { bx("ab").size(foo: 1) }
try { bx([1, 2, 3]).empty?(foo: 1) }
try { bx({a: 1}).invert(foo: 1) }

try { "ab".send(:size, foo: 1) }
try { [1, 2, 3].send(:reverse, foo: 1) }

try { "ab".size(1) }
try { [1, 2, 3].first(1, 2) }
try { 7.succ(1) }

try { "ab".size(foo: note(:value)) }
p $log

p 2.5.round(half: :even)
p "a\nb\n".lines(chomp: true)
p [1, 2, 3].sample(random: Random.new(1)).class
p "ab".size
