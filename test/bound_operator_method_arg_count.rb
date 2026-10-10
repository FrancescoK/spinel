# A bound operator's or [] Method takes the count of operands CRuby's takes:
# one for an operator and a Hash's [], one or two for an Array's or a
# String's []. A splat is counted once it is spread, wherever it stands, so
# an empty one does not let fixed arguments past the count and a long one
# is not cut to it.
def try(label)
  p yield
rescue ArgumentError => e
  puts "#{label}: #{e.message}"
end
try("plus_over") { 5.method(:+).call(1, 2) }
try("plus_splat_long") { 5.method(:+).call(1, *[2]) }
try("plus_splat_empty") { 5.method(:+).call(1, 2, *[]) }
try("plus_splat_one") { 5.method(:+).call(*[1]) }
try("plus_splat_none") { 5.method(:+).call(*[]) }
try("plus_splat_first") { 5.method(:+).call(*[1], 2) }
ops = [3]
try("times_splat_local") { 5.method(:*).call(*ops) }
try("str_plus_splat") { "ab".method(:+).call(*["cd"]) }
try("float_plus_splat") { 1.5.method(:+).call(*[2]) }
h = { a: 1 }
try("hash_index_splat_long") { h.method(:[]).call(:a, *[:b]) }
try("hash_index_splat_empty") { h.method(:[]).call(:a, :b, *[]) }
try("hash_index_splat_one") { h.method(:[]).call(*[:a]) }
arr = [1, 2, 3]
try("array_index_over") { arr.method(:[]).call(0, 1, 2) }
try("array_index_splat_empty") { arr.method(:[]).call(0, 1, 2, *[]) }
try("array_index_splat_long") { arr.method(:[]).call(0, *[1, 2]) }
none = []
try("array_index_splat_one") { arr.method(:[]).call(1, *none) }
pair = [0, 2]
try("array_slice_splat") { arr.method(:[]).call(*pair) }
try("array_slice") { arr.method(:[]).call(1, 2) }
try("string_index_over") { "hello".method(:[]).call(0, 2, 3) }
