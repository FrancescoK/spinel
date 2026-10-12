# Under --share-strings a String `||` or `&&` with a bang method on a boxed
# receiver on an arm (`e.rstrip! || "w"`, e an element of a mixed Array),
# kept by map or pushed onto an Array, keeps the receiver's String itself
# when the bang answers it: a change through the kept value shows through
# the Array the receiver came from.
mix = [+" ab ", 1, +"cd ", +"EF"]
outs = mix.values_at(0, 2, 3).map { |e| e.rstrip! || ("w" * 3) }
p outs, outs[0].equal?(mix[0]), outs[2].equal?(mix[3])
outs[1] << "+"
p mix
outs = mix.values_at(0, 2, 3).map { |e| e.downcase! && "d" }
p outs, mix
arr = []
mix.each { |e| arr << (e.upcase! || "n") if e.is_a?(String) }
arr[0] << "%"
p arr, mix
