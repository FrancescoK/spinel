# Integer#div with a Float divisor: zero is ZeroDivisionError, NaN is
# FloatDomainError, the rest floors the real quotient.
def try(n)
  p [n, yield]
rescue ZeroDivisionError, FloatDomainError, NoMethodError => e
  p [n, e.class, e.message]
end

try(:zero) { 10.div(0.0) }
try(:neg_zero) { 10.div(-0.0) }
try(:zero_by_zero) { 0.div(0.0) }
try(:neg_by_zero) { -5.div(0.0) }
try(:big_by_zero) { (2**62).div(0.0) }
try(:nan) { 10.div(Float::NAN) }
try(:inf) { 10.div(Float::INFINITY) }
try(:neg_inf) { 10.div(-Float::INFINITY) }
try(:inf_neg_recv) { -10.div(Float::INFINITY) }
try(:half) { 7.div(2.5) }
try(:neg_half) { -7.div(2.5) }
try(:neg_div) { 7.div(-2.5) }
try(:fifth) { 7.div(0.5) }
try(:exact) { 6.div(1.5) }
try(:small) { 1.div(3.0) }
try(:neg_small) { -1.div(3.0) }
try(:zero_recv) { 0.div(2.5) }

z = 0.0
try(:var_zero) { 10.div(z) }
try(:var_map) { [10, 20].map { |v| v.div(z) } }
n = Float::NAN
try(:var_nan) { 10.div(n) }
h = 2.5
try(:var) { 10.div(h) }
try(:var_map_ok) { [10, 20].map { |v| v.div(h) } }
def zero = 0.0
try(:method_zero) { 10.div(zero) }
try(:array_zero) { [0.0][0].then { |x| 10.div(x) } }
try(:hash_zero) { { k: 0.0 }[:k].then { |x| 10.div(x) } }
try(:expr_zero) { 10.div(1.5 - 1.5) }

log = []
try(:order) { (log << :recv; 10).div((log << :arg; 0.0)) }
p log
log = []
try(:order_ok) { (log << :recv; 10).div((log << :arg; 4.0)) }
p log

# Integer#ceildiv is built on div
try(:ceil_zero) { 7.ceildiv(0.0) }
try(:ceil_neg_zero) { 7.ceildiv(-0.0) }
try(:ceil_nan) { 7.ceildiv(Float::NAN) }
try(:ceil) { 7.ceildiv(2.5) }

# a nil receiver still raises NoMethodError
try(:nil_recv) { [1][5].div(0.0) }

# Float and mixed receivers already raised
try(:float_recv) { 10.0.div(0.0) }
try(:float_recv_int) { 10.0.div(0) }
try(:int_int) { 10.div(0) }
