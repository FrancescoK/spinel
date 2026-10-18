# The same through chars: each appends to the element Strings in place.
cs = "ab".chars
cs.each { |ch| ch << "!" }
p cs
