# Compound index assignment on a typed array with a poly right-hand side:
# `float_array[i] += b[0]` where b is a heterogeneous (poly) array. The
# emitter added the boxed sp_RbVal straight to the unboxed slot
# (`double + sp_RbVal`), failing C compilation, while the equivalent plain
# form `a[i] = a[i] + b[0]` already folded through the tag-dispatching
# sp_poly_add. Also covers the str_array `+=` slot (native `char* + char*`
# never compiled, poly RHS or not) and `+=` on a poly_array receiver.

# float_array[i] += poly: literal index, variable index, inside a loop
a = Array.new(2, 0.0)
b = [1.5, "x"]
a[0] += b[0]
r = 1
a[r] += b[0]
p a                # [1.5, 1.5]
i = 0
while i < 2
  a[i] += b[0]
  i += 1
end
p a                # [3.0, 3.0]
a[0] -= b[0]
a[0] *= b[0]
a[1] /= b[0]
p a                # [2.25, 2.0]

# int_array[i] with a poly RHS: arithmetic folds via the dynamic operator,
# shifts unbox the RHS
n = [10, 20]
m = [3, "x"]
n[0] += m[0]
n[1] -= m[0]
n[0] *= m[0]
p n                # [39, 17]
n[0] <<= m[0]
p n                # [312, 17]

# str_array[i] += string and += poly-carried string
s = ["ab", "cd"]
s[0] += "!"
t = ["ef", 1]
s[1] += t[0]
p s                # ["ab!", "cdef"]

# str_array[i] <<= (String#<< appends) and *= (String#* repeats)
u = [+"x", +"y"]
u[0] <<= "z"
u[1] *= 3
p u                # ["xz", "yyy"]

# same ops when the analyzer demotes the receiver to poly_array
# (mixing *= and <<= on one array does that): the fold goes through
# sp_poly_mul / sp_poly_shl, which handle the String arms
w = [+"ab", +"cd"]
w[0] *= 2
w[1] <<= "!"
p w                # ["abab", "cd!"]

# poly_array receiver: += float / int / poly slot
pa = [1.5, "x", 2]
pa[0] += 2.0
pa[2] += 5
pa[0] += pa[2]
p pa[0]            # 10.5
p pa[2]            # 7
