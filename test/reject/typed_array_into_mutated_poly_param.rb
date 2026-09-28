# A typed array passed to a general-Array parameter the method mutates: the
# conversion is a copy, so the appends would not reach the caller's array
# (a report's `collect(o, ctx.tbl)` came back with o empty, #4480). Here
# `out` is a general Array because Float rows are concatenated into it, and
# the caller passes an Array[Integer] a method built, which the binding
# cannot widen; the concat used to land in a copy and `o` stayed `[]`.
# Refused at compile time.
def grow(out)
  out.concat([1.5, 2.5])
end
def blank = Array.new(0, 0)
o = blank
grow(o)
p o
