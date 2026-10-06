# A lazy stage's block that changes its String element in place: the
# pipeline hands the block a copy of the element, so the String the source
# holds would not change (it crashed). Refused, naming the line.
s = +"abc"
[s].lazy.map { |x| x << "!" }.first
p s
