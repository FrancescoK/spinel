# Numeric#step with a nil limit has no end (an Enumerator), also when the
# receiver's type is only known at run time (a boxed Integer or Float, or
# any Integer under --int-overflow=promote). The boxed receiver's dispatch
# built the finite Array instead and converted the nil limit, raising
# "no implicit conversion from nil to integer".
int_or_float = ARGV.size > 0 ? 1.5 : 2
float_or_int = ARGV.size > 0 ? 2 : 0.5
p int_or_float.step(nil, 3).first(3)
p int_or_float.step(nil, -2).first(3)
p int_or_float.step(by: 2, to: nil).first(2)
p float_or_int.step(nil, 0.25).first(3)
$order = []
def step_recv(v) = ($order << :recv; v)
def step_by(v) = ($order << :step; v)
p step_recv(int_or_float).step(nil, step_by(4)).first(2), $order
begin
  p int_or_float.step(nil, 0).first(1)
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end
