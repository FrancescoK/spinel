def t(label)
  r = yield
  p [label, r]
rescue => e
  p [label, e.class, e.message]
end
t(:s) { 2.pow(3, "x") }
t(:f) { 2.pow(3, 2.0) }
t(:neg) { 2.pow(-1, 5) }
t(:zero) { 2.pow(3, 0) }
t(:ok) { 2.pow(10, 7) }
t(:negmod) { 2.pow(3, -5) }
t(:fbase) { 2.pow(3.0, 5) }
t(:nil) { 2.pow(3, nil) }
t(:kw) { 2.pow(foo: 1) }
b = [2, nil][0]
t(:b_s) { b.pow(3, "x") }
t(:b_f) { b.pow(3, 2.0) }
t(:b_neg) { b.pow(-1, 5) }
o = Object.new
def o.to_int = 5
t(:to_int_mod) { 2.pow(3, o) }
t(:to_int_exp) { 2.pow(o, 5) }
t(:neg_str) { 2.pow(-1, "x") }
t(:big_mod) { 2.pow(3, 2**70) }
b2 = [3, nil][0]
t(:b_exp) { 2.pow(b2, 7) }
t(:big_mod_fexp) { 2.pow(3.0, 2**70) }
t(:big_mod_sexp) { 2.pow("3", 2**70) }
t(:big_mod_neg) { 2.pow(-1, 2**70) }
t(:big_mod_bigexp) { 2.pow(2**5, 2**70) }
