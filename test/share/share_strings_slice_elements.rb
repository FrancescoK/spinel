# Flag-only: slices are fresh Arrays holding the receiver's String objects.
# Mutating a String through a slice, a local or an Enumerator reaches the
# source Array; replacing a slice's element does not replace the source's.
single = [+"x", +"y"]
single.each_slice(1) { |one| one[0] << "!" }
p single

paired = [+"x", +"y", +"z"]
paired.each_slice(2) { |pair| pair[0] << "!" }
p paired

overlapping = [+"x", +"y", +"z"]
overlapping.each_cons(2) { |window| window[0] << "!"; window[1] << "?" }
p overlapping

deferred = [+"x", +"y"]
slices = deferred.each_slice(1)
slices.each { |part| part[0] << "!" }
p deferred

named = [+"x", +"y"]
named.each_slice(1) { |piece| s = piece[0]; s << "!" }
p named

replaced = [+"x", +"y"]
replaced.each_slice(1) { |copy| copy[0] = +"z" }
p replaced
