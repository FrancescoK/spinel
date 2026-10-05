# The two fast paths a Float array element takes in a loop that holds the
# array's header, pinned by infer-test on the emitted C:
#  - `a[i] += K` with K a constant folds in place like `a[i] += 4`: a
#    constant the program defines is a plain read (subtree_is_pure_read).
#  - `a[i] + F` reads the element nil-free in range, as op-assign does, and
#    only the fallback raises on a nil (sp_FloatArray_get_recv); there is no
#    up-front SP_FLOAT_NIL_CK of both operands in the loop.
K = 4
F = 0.5

def opw_const(a, n)
  i = 0
  while i < n
    a[i] += K
    i += 1
  end
end

def binary_elem(a, n)
  i = 0
  while i < n
    a[i] = a[i] + F
    i += 1
  end
end

a = Array.new(8, 0.5)
opw_const(a, 8)
binary_elem(a, 8)
