# sum on a boxed Hash or String array adds the elements from 0 as CRuby
# does, which raises TypeError for a pair or a String -- not a silent 0.
def s(o) = o.sum
def try(label)
  p [label, yield]
rescue TypeError => e
  p [label, e.class, e.message]
end
try(:hash) { s({ a: 1 }) }
try(:empty_hash) { s({}) }
try(:str_array) { s(["a"]) }
try(:empty_str_array) { s([""].take(0)) }
try(:int_array) { s([1, 2]) }
try(:sym_array) { s([:a]) }
try(:range) { s(1..3) }
