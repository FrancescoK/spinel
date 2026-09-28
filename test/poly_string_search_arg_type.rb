# String#index / #rindex / #count / #include? on a boxed String: the
# argument is a String (or a Regexp for index/rindex); anything else is a
# TypeError, and member?/key? are not String methods at all.
def try(label)
  p [label, yield]
rescue TypeError, NoMethodError => e
  p [label, e.class, e.message[0, 45]]
end

def ix(o, a) = o.index(a)
def rx(o, a) = o.rindex(a)
def ix2(o, a, i) = o.index(a, i)
def rx2(o, a, i) = o.rindex(a, i)
def ct(o, a) = o.count(a)
def inc(o, a) = o.include?(a)
def mem(o, a) = o.member?(a)
def key(o, a) = o.key?(a)

try(:index_arr) { ix([5, 1], 1) }
try(:index_str) { ix("ab", "b") }
try(:index_int) { ix("ab", 1) }
try(:index_nil) { ix("ab", nil) }
try(:index_re) { ix("aéb", /b/) }
try(:rindex_arr) { rx([5, 1], 1) }
try(:rindex_int) { rx("ab", 1) }
try(:rindex_re) { rx("abab", /b/) }
try(:index_from_re) { ix2("abab", /b/, 2) }
try(:rindex_from_re) { rx2("abab", /b/, 2) }
try(:count_int) { ct("ab", 1) }
try(:count_str) { ct("abca", "a") }
try(:count_arr) { ct([1, 1], 1) }
try(:include_int) { inc("ab", 1) }
try(:include_arr) { inc([1], 1) }
try(:member_str) { mem("ab", "a") }
try(:member_arr) { mem([1], "a") }
try(:key_str) { key("ab", "a") }
try(:key_hash) { key({ "a" => 1 }, "a") }
x = ["b", 1]
try(:include_boxed_str) { inc("ab", x[0]) }
try(:include_boxed_int) { inc("ab", x[1]) }
try(:include_arr_boxed) { inc([1], x[1]) }
