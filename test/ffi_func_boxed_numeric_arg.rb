# spinel: int64 -- assumes a 64-bit Integer (values or arithmetic past 2^31); not run on a 32-bit target
# spinel: not-cruby -- ffi_source / ffi_func are spinel's; the .expected is CRuby with the ffi gem and attach_function.
# A boxed value where an ffi_func argument or an ffi_callback's return is a
# C integer or double converts as the ffi gem's NUM2LONG / NUM2DBL do. An
# Integer read as a double passed its bits (16 arrived as 8e-323), a Float
# read as an integer passed its bits, and a String or a Symbol passed its
# pointer or its ID instead of the TypeError.
module B
  ffi_source <<~'C'
    double sp_probe_dbl(double x) { return x; }
    long sp_probe_long(long x) { return x; }
    int sp_probe_int(int x) { return x; }
    float sp_probe_flt(float x) { return x; }
    typedef double (*sp_probe_dcb)(double);
    double sp_probe_dapply(sp_probe_dcb f, double x) { return f(x); }
    typedef long (*sp_probe_lcb)(long);
    long sp_probe_lapply(sp_probe_lcb f, long x) { return f(x); }
  C
  ffi_callback :dcb, [:double], :double
  ffi_callback :lcb, [:long], :long
  ffi_func :sp_probe_dbl, [:double], :double
  ffi_func :sp_probe_long, [:long], :long
  ffi_func :sp_probe_int, [:int], :int
  ffi_func :sp_probe_flt, [:float], :float
  ffi_func :sp_probe_dapply, [:dcb, :double], :double
  ffi_func :sp_probe_lapply, [:lcb, :long], :long
end

def try
  yield
rescue TypeError => e
  puts "TypeError: #{e.message}"
end

# a parameter that takes an Integer and a Float
def dbl(x) = B.sp_probe_dbl(x)
def long(x) = B.sp_probe_long(x)
def int(x) = B.sp_probe_int(x)
def flt(x) = B.sp_probe_flt(x)
p dbl(16)
p dbl(2.25)
p long(-7)
p long(-2.75)
p int(9)
p int(-2.75)
p flt(25)
p flt(6.25)

# a local that holds an Integer or a Float
x = 16
x = 2.25 if ARGV.size > 5
p B.sp_probe_dbl(x)
y = -2.75
y = 3 if ARGV.size > 5
p B.sp_probe_long(y)

# an element of a mixed Array
xs = [16, -2.75, nil, "s", :a, true, Rational(9, 2), 10**30]
p B.sp_probe_dbl(xs[0])
p B.sp_probe_long(xs[1])
p B.sp_probe_dbl(xs[6])
p B.sp_probe_long(xs[6])
p B.sp_probe_dbl(xs[7])

# a value that is no number raises the gem's TypeError
xs[2, 4].each do |v|
  try { p B.sp_probe_dbl(v) }
  try { p B.sp_probe_long(v) }
end
# a String the program appends to is boxed as a shared handle
s = +"4"
s << "2"
try { p B.sp_probe_dbl([s, 1][0]) }

# NUM2DBL converts any other value by its #to_f
[Time.at(5), Complex(1, 0), 1].each { |v| p B.sp_probe_dbl(v) }
begin
  p B.sp_probe_dbl([Complex(1, 2), 1][0])
rescue RangeError => e
  puts "RangeError: #{e.message}"
end

# a callback that answers an Integer or a Float
def dmix(x) = x > 0 ? 3 : 2.5
def lmix(x) = x > 0 ? 4 : -2.75
p B.sp_probe_dapply(method(:dmix), 1.0)
p B.sp_probe_dapply(method(:dmix), -1.0)
p B.sp_probe_lapply(method(:lmix), 1)
p B.sp_probe_lapply(method(:lmix), -1)
