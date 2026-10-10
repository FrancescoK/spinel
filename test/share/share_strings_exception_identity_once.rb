# spinel: share
# spinel: gc-minor
# An identity compare of an exception's message, or of a boxed value's to_s,
# evaluates each operand once and runs an override of the text once per read.
$n = 0
$calls = 0
class A < StandardError
  def to_s
    $calls += 1
    "over"
  end
end
class B < StandardError; end
def pk(k)
  $n += 1
  k == 0 ? "s" : 5
end
def pick(k)
  $n += 1
  k == 0 ? B.new(+"b") : A.new
end
n = ARGV.size
p pk(n).to_s.equal?(pk(1).to_s), $n
x = n == 0 ? A.new : B.new("b")
p x.message.equal?(x.message), $calls
$n = 0
p pick(n).message.equal?(pick(1).message), $n, $calls
p pick(n).to_s.equal?(pick(n).to_s), $n, $calls
z = n == 0 ? A.new : "str"
p z.to_s.equal?(z.to_s), $calls
# a boxed value that is no exception: its to_s is itself
c = +"m#{n}"
d = c
c << "!"
y = n == 0 ? c : 5
p y.to_s.equal?(c), y.to_s.equal?(d), d
s = +"note#{n}"
t = s
s << "!"
arr = [s, "lit"]
p arr[1].to_s.equal?("lit"), arr[0].to_s.equal?(t)
