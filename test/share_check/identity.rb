# The operands of equal?, object_id and __id__ have a consumer role of their
# own in the String plan (#8328): an identity is the handle where the value
# has one and its bytes' pointer where it is bytes only, never a new handle.
# A String Range's endpoints (begin, end, first, last, min, max) stored as
# elements hand over the handle the Range keeps, as the C does.
a = +"a"; b = +"c"; r = a..b; a << "1"; b << "2"
xs = [r.begin, r.end, r.first, r.last, r.min, r.max]
p xs[0].equal?(r.begin), xs[1].equal?(r.end), xs[4].equal?(r.min), xs[5].equal?(r.max)
p xs[0].equal?(a), xs[3].equal?(b), a.object_id == xs[2].object_id
lit = "lit"
same = lit
p lit.equal?(same), lit.__id__ == same.__id__, lit.equal?(+"lit")
