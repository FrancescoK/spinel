# A method reached only through an ffi_callback takes the callback's
# declared argument types, as it would from a call site. Its parameters
# stayed Integer, and the trampoline cast a double to sp_int: 1.5 arrived
# as 1. (ffi_func is spinel's own; this .expected is written by hand from
# what C hands the method.)
module CB
  ffi_source <<~'C'
    typedef double (*sp_cbt_dd)(double, double);
    double sp_cbt_apply2(sp_cbt_dd f, double a, double b) { return f(a, b); }
    typedef long (*sp_cbt_ld)(long, double);
    long sp_cbt_mixed(sp_cbt_ld f, long a, double b) { return f(a, b); }
  C
  ffi_callback :dd, [:double, :double], :double
  ffi_callback :ld, [:long, :double], :long
  ffi_func :sp_cbt_apply2, [:dd, :double, :double], :double
  ffi_func :sp_cbt_mixed, [:ld, :long, :double], :long
end

def add(a, b)
  p [a, b]
  a + b
end

def scale(n, f)
  p [n, f]
  (n * f).round
end

p CB.sp_cbt_apply2(method(:add), 1.5, 2.25)
p CB.sp_cbt_mixed(method(:scale), 3, 2.5)
