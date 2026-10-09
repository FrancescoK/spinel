def show
  p yield
rescue => e
  puts "#{e.class}: #{e.message}"
end

show { 1.step(by: 2, to: nil).first(3) }
show { 1.step(nil, 2).first(3) }
show { 1.0.step(by: 0.5, to: nil).first(3) }
show { 1.step(nil).first(3) }
show { 1.step(to: nil).first(3) }
show { 1.step.first(3) }
show { 1.step(nil, 0.5).first(3) }
show { 1.step(nil, 0).first(2) }
show { 1.step(by: 2, to: 7).to_a }
r = []
1.step(nil, 3) { |i| r << i; break if r.size == 3 }
p r
t = [nil, 9][0]
r = []
1.step(t, 2) { |i| r << i; break if r.size == 3 }
p r
t = [nil, 7][1]
r = []
1.step(t, 2) { |i| r << i }
p r

show { "  ab  ".strip }
show { "xxabxx".strip("x") }
show { "xxab".lstrip("x") }
show { "abxx".rstrip("x") }
show { "abcxcba".strip("a-c") }
show { "xyab".strip("x", "y") }
show { "aabcaa".strip("^b") }
show { " xab ".strip("x") }
show { " ab ".strip(9) }
show { " ab ".strip(nil) }
show { "ab".lstrip(:a) }
c = ["x", "y"][0]
show { "xxabxx".strip(c) }
s = +"xabx"
show { s.strip!("x") }
p s
show { (+"ab").strip!("x") }

show { "ab".upcase(:ascii) }
show { "ab".upcase(:foo) }
show { "ab".upcase(foo: 1) }
show { "ab".upcase(:ascii, :turkic) }
show { "ab".upcase(:fold) }
show { "AB".downcase(:fold) }
show { "AB".downcase(foo: 1) }
show { "ab".capitalize(:foo) }
show { "ab".swapcase(foo: 1) }
show { "ab".upcase(**{}) }
show { :ab.upcase(foo: 1) }
u = +"ab"
show { u.upcase!(foo: 1) }
p u

bin = "\xFFab\xFF".b
[bin.strip("\xFF".b), bin.lstrip("\xFF".b), bin.rstrip("\xFF".b), "xa\xE9bx".b.strip("x")].each { |r| p r, r.encoding, r.bytes }
p "aab".strip("a").encoding

$order = []
def step_recv(v) = ($order << :recv; v)
def step_by(v) = ($order << :step; v)
p step_recv(1).step(nil, step_by(2)).first(3), $order
x = 1
p (x += 1; x).step(nil, (x *= 10; x)).first(3)
