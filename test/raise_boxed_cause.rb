# `raise X, cause: c` where c is known only at run time -- the first of a
# collected list of exceptions, as activesupport's instrumentation
# re-raises its subscribers' errors -- takes c as the cause, and nil as
# no cause. The boxed value was cast to the cause pointer as it was, and
# the C did not compile.
def first_of(xs) = xs.first
errs = []
begin
  raise "a"
rescue => e
  errs << e
end
begin
  raise ArgumentError, "b", cause: first_of(errs)
rescue => f
  p [f.message, f.cause.message]
end
begin
  raise ArgumentError, "c", cause: first_of([])
rescue => g
  p [g.message, g.cause]
end
