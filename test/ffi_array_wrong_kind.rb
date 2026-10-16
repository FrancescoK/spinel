# spinel: not-cruby -- the spinel-native FFI DSL; the .expected is authored
# An Array of the other element kind given an ffi_func :float_array or
# :int_array raises the TypeError a boxed one does; the typed one was cast
# to the data pointer and its elements read as the other kind (#9092).
# A right-kind Integer Array reaches the int64_t * whole on a 32-bit target
# too, where its elements are 32 bits and were read two at a time.
module L
  ffi_source <<~C
    double sum_d(const double *a, long n) { double s = 0; for (long i = 0; i < n; i++) s += a[i]; return s; }
    long sum_i(const int64_t *a, long n) { long s = 0; for (long i = 0; i < n; i++) s += a[i]; return s; }
  C
  ffi_func :sum_d, [:float_array, :long], :double
  ffi_func :sum_i, [:int_array, :long], :long
end
p L.sum_d([1.5, 2.5], 2)
p L.sum_i([1, 2, 3], 3)
begin
  p L.sum_d([1, 2], 2)
rescue TypeError => e
  puts "int into float_array -> #{e.message}"
end
begin
  p L.sum_i([1.0, 2.0], 2)
rescue TypeError => e
  puts "float into int_array -> #{e.message}"
end
