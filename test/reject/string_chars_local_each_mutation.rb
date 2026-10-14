# The same through chars: each appends to the element Strings in place.
# spinel: reject-thread-string
cs = "ab".chars
cs.each { |ch| ch << "!" }
p cs
