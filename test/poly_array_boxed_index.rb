# A mixed array indexed by a value that may be an Integer or a Range reads
# an element or a sub-array by what the index is at run time.
# activesupport's ArrayInquirer#[] is `@array[*args]`. The index was read
# as an Integer whatever it held, so a Range read element 0.
def at(a, i) = a[i]
arr = [1, "b", :c]
p at(arr, 1)
p at(arr, 0..1)
p at(arr, -1)
p at(arr, 1...)
begin
  at(arr, [nil].first)
rescue TypeError => e
  p e.message
end
