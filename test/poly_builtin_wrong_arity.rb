# A call on a boxed receiver with a count no builtin takes raises CRuby's
# ArgumentError, with the range of the class the receiver has at run time;
# a receiver whose class lacks the method still raises NoMethodError.
def try(label)
  yield
  p [label, :ran]
rescue ArgumentError => e
  p [label, e.class, e.message]
rescue NoMethodError => e
  p [label, e.class]
end

x = [[1, 2], 5, "s", { a: 1 }, nil]
a = x[0]; i = x[1]; s = x[2]; h = x[3]
try(:arr_plus0) { a.+() }
try(:arr_minus0) { a.-() }
try(:arr_cmp0) { a.<=>() }
try(:int_plus0) { i.+() }
try(:int_lt0) { i.<() }
try(:str_plus0) { s.+() }
try(:str_eq0) { s.==() }
try(:hash_aref0) { h.[]() }
try(:arr_first2) { a.first(1, 2) }
try(:arr_size1) { a.size(1) }
try(:int_abs1) { i.abs(1) }
try(:hash_keys1) { h.keys(1) }
try(:arr_plus2) { a.+([1], [2]) }
try(:str_center0) { s.center }
try(:arr_fetch0) { a.fetch }

x.each do |o|
  try(:plus0) { o.+() }
  try(:size1) { o.size(1) }
end

# A name another builtin answers at this count is not a wrong count there:
# an exception's own accessors (Hash#key takes one argument, KeyError#key
# none) keep answering through a boxed receiver.
ke = begin; { 5 => 0 }.fetch(9); rescue KeyError => z; z; end
si = [1].each
si.next
st = begin; si.next; rescue StopIteration => z; z; end
errs = [ke, st, { a: 1 }]
p errs[0].key, errs[0].receiver
p errs[1].result
try(:hash_key0) { errs[2].key }
try(:hash_key1) { p errs[2].key(1) }
